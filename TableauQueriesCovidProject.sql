/*

Queries used for Tableau Project

*/



-- 1. 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths
where continent not in ('') 
-- Group By date
order by 1,2;



-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

select location, sum(cast(new_deaths as int)) as TotalDeathCount
from portfolioproject.coviddeaths
where continent in ('') 
	and location not in ('World', 'International') 
	and location not like '%income%'
	and location not like '%European%'
group by location
order by TotalDeathCount desc;




-- 3.

select location, population , max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject.coviddeaths
group by location, population
order by PercentPopulationInfected desc;



-- 4.

select location, population, new_date_column, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From portfolioproject.coviddeaths
Group by location, population, new_date_column
order by PercentPopulationInfected desc;

