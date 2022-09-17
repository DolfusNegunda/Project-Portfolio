Data Exploration
-- Covid-19 Data (Feb 2020 - Apr 2021) [ourworldindata.org]

Select location, continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
-- Adding the 'Where' statement below reveals that the first case in South Africa was on the fifth of March 2022
-- Where location = 'South Africa'
Where continent is not Null
Order by 1,2,3

-- Total Cases vs Total Deaths (%)
Select location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS 'death_percentage'
From PortfolioProject..CovidDeaths
--Where location = 'South Africa'
Order by 1,2,3
-- By the end of 2020 we had a death rate of 2.69 due to Covid

-- Total cases vs population (%)
Select location, date, population, total_cases, ((total_cases/population) * 100) AS 'infected_population_percentage'
From PortfolioProject..CovidDeaths
--Where location = 'South Africa'
Order by 1,2,3

-- Searching for country with the highest infection % in relation to the population
Select location, population, Max(total_cases) AS 'highest_count_of_infected_population', Max(((total_cases/population)) * 100) AS 'infected_population_percentage'
From PortfolioProject..CovidDeaths
Group by location, population
Order by 'infected_population_percentage' Desc

-- In the next section I'll be showing countries with the highest death counts
-- This section includes some data challanges. 
-- Start of section
Select location, Max(total_deaths) AS 'total_death_count'
From PortfolioProject..CovidDeaths
Group by location
Order by 'total_death_count' desc

-- Solution to above query
Select location, Max(cast(total_deaths AS int)) AS 'total_death_count'
From PortfolioProject..CovidDeaths
-- Where statement filters out continents in the total death counts 
Where continent is not Null
Group by location
Order by 'total_death_count' desc
-- End of section

-- Grouping by continents (Above codes applicable too, replace location with continent)
Select continent, Max(cast(total_deaths AS int)) AS 'total_death_count'
From PortfolioProject..CovidDeaths
-- Where statement filters out continents in the total death counts 
Where continent is not Null
Group by continent
Order by 'total_death_count' desc

-- Global analysis
-- Total cases and deaths per day
Select date, Sum(new_cases) AS 'total_cases', Sum(cast(new_deaths as float)) AS 'total_deaths', 
((Sum(cast(new_deaths as float))/Sum(new_cases)) * 100) AS 'death_percentage'
From PortfolioProject..CovidDeaths
--Where location = 'South Africa'
Where continent is not Null
Group by date
Order by 1,2,3

-- Population vaccinated
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations 
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null
Order by 2,1,3

-- Creating a rolling count of Vaccinations
-- Sum(Convert(int, Vacc.new_vaccinations)) = Sum(cast(Vacc.new_vaccinations as int))
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(Convert(int, Vacc.new_vaccinations)) Over (Partition by Death.location Order by Death.location, Death.date) AS 'total_vaccinations'
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null
Order by 2,1,3

-- Showing vaccinations in South Africa
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(Convert(int, Vacc.new_vaccinations)) Over (Partition by Death.location Order by Death.location, Death.date) AS 'total_vaccinations'
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null and Death.location = 'South Africa'
Order by 2,1,3
-- Vaccinations in South Africa started on the 19th of Feb 2021 with 4264 people vaccinated on the day

-- To perform further calculations using a newly created column eg. 'total_vaccinations' we use CTEs
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(Convert(int, Vacc.new_vaccinations)) Over (Partition by Death.location Order by Death.location, Death.date) AS 'total_vaccinations'
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null
Order by 2,1,3

-- Using CTE
With VaccinatedPopulation (continent, location, date, population, new_vaccinations, total_vaccinations)
As
(Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(Convert(int, Vacc.new_vaccinations)) Over (Partition by Death.location Order by Death.location, Death.date) AS 'total_vaccinations'
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null
)
--Must be ran with above query
Select *, ((total_vaccinations/population) * 100) AS 'total_vaccination_percentage'
From VaccinatedPopulation
-- Where location = 'South Africa'

-- Alternative to CTE is Temp tables
Drop Table if Exists #VaccinatedPopulation
-- Line 116 is good protocall for Temp tables
Create Table #VaccinatedPopulation
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
total_vaccinations int
)

Insert into #VaccinatedPopulation
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(Convert(int, Vacc.new_vaccinations)) Over (Partition by Death.location Order by Death.location, Death.date) AS 'total_vaccinations'
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null
Order by 2,1,3

Select *, (total_vaccinations/population) * 100 AS 'total_vaccination_percentage'
From #VaccinatedPopulation 

Create View VaccinatedPopulation As
Select Death.continent, Death.location, Death.date, Death.population, Vacc.new_vaccinations, 
Sum(Convert(int, Vacc.new_vaccinations)) Over (Partition by Death.location Order by Death.location, Death.date) AS 'total_vaccinations'
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vacc
on Death.location = Vacc.location and Death.date = Vacc.date
Where death.continent is not Null
-- Order by 2,1,3

Select * 
From VaccinatedPopulation
