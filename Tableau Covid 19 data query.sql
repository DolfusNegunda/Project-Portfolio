-- Queries for Tableau projects

-- Table 1
Select SUM(new_cases) as 'total_cases', SUM(cast(new_deaths as int)) as 'total_deaths', SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location = 'South Africa'
Where continent is not Null 
-- Group By date
Order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International" Location

-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
-- From PortfolioProject..CovidDeaths
-- Where location = 'South Africa'
-- Where location = 'World'
-- Group By date
-- Order by 1,2

-- Table 2 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
-- Where location = 'South Africa'
Where continent is Null and location not in ('World', 'European Union', 'International')
Group by location
Order by total_death_count Desc

-- Table 3
Select Location, Population, MAX(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
-- Where location = 'South Africa'
Group by Location, Population
Order by percent_population_infected Desc

-- Table 4
Select Location, Population, date, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
-- Where location = 'South Africa'
Group by location, population, date
order by percent_population_infected Desc