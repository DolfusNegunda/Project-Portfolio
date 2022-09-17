Select firstname,lastname, age,
case
when age is null then 'Age info missing'
when age > 30 then 'Elderly'
else 'Young'
end
from EmployeeDemographics
order by age