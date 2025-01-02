use portfolioproject;

-- Alter the existing table in order to convert the Date column from TEXT to DATE
-- ALTER TABLE coviddeaths DROP COLUMN new_date_column;
-- ALTER TABLE covidvaccins DROP COLUMN new_date_column;

ALTER TABLE coviddeaths ADD COLUMN new_date_column DATE;

UPDATE coviddeaths
SET new_date_column = STR_TO_DATE(date, '%d/%m/%Y');

select location, new_date_column, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths
order by 1,2;

ALTER TABLE covidvaccins ADD COLUMN new_date_column DATE;

UPDATE covidvaccins
SET new_date_column = STR_TO_DATE(date, '%Y-%m-%d');

select location, new_date_column, total_tests, total_vaccinations 
from portfolioproject.covidvaccins
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
select location, new_date_column, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths
where location like '%italy%'
order by 1,2;

-- Looking at the Total Cases vs Population
-- Shows the percentage of population that contracted covid
select location, new_date_column, population, total_cases, (total_cases/population)*100 as ContractionPercentage
from portfolioproject.coviddeaths
where location in ('United States')
order by 1,2;

-- Looking at countries with highest infection rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as ContractionPercentage
from portfolioproject.coviddeaths
group by location, population 
order by ContractionPercentage desc;

-- Looking at the countries with the highest death count per population
select location, continent, max(total_deaths) as TotalDeathCount, max((total_deaths/population))*100 as DeathPercentage
from portfolioproject.coviddeaths
where continent not in ('')
group by location 
order by TotalDeathCount desc;

-- Looking at the continents with the highest death count per population
select location, max(total_deaths) as TotalDeathCount
from portfolioproject.coviddeaths
where continent in ('')
group by location 
order by TotalDeathCount desc;

-- Looking at the continents with the highest death count per population -> different way
select continent, max(total_deaths) as TotalDeathCount
from portfolioproject.coviddeaths
where continent not in ('')
group by continent 
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
select new_date_column, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
-- select new_date_column, sum(new_cases) as global_total_cases, sum(new_deaths) as global_total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from portfolioproject.coviddeaths
where continent not in ('')
group by new_date_column
order by new_date_column asc;



-- TABLE COVID VACCINATIONS : let's try to look at Total Population vs Vaccinations

-- Using table covidvaccins, let's see hot to compute a Rolling People Vaccinations (cumulative sum of new vaccines injected every day)
-- To check if the query is ok, let's filter on a single location
select vac.continent, vac.location, vac.new_date_column,
	vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int))
		over (partition by vac.location order by vac.location,vac.new_date_column) 
		as RollingPeopleVaccinated
from portfolioproject.covidvaccins as vac
where vac.continent not in ('')
and vac.location = 'Albania';

-- We need to have the population data in order to get a comparison between the cumulative number of vaccinated people over the overall population
-- Population data are stored in coviddeaths table, so we need to join coviddeaths and covidvaccins
-- To check if the query is ok, let's filter on a single location
select dea.continent, dea.location, dea.new_date_column, dea.population,
	vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int))
		over (partition by vac.location order by vac.location,vac.new_date_column) 
		as RollingPeopleVaccinated
from portfolioproject.coviddeaths as dea
join portfolioproject.covidvaccins as vac
	on  dea.location = vac.location
	and dea.new_date_column = vac.new_date_column 
where dea.location = 'Albania';


-- Let's try to use a temporary table in order to get both Population and Vaccins in the same table
-- This should help in terms of computation time

drop table if exists PercentPopulationVaccinated;

create table PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime, 
	Population numeric,
	New_Vaccinations numeric,
	RollingVaccinations numeric,
	RollingPeopleVaccinated float
)

insert into percentpopulationvaccinated 
select dea.continent, dea.location, dea.new_date_column, dea.population, vac.new_vaccinations_integer,
	sum(vac.new_vaccinations_integer)
		over (partition by vac.location order by vac.location,vac.new_date_column),
	(sum(vac.new_vaccinations_integer)
		over (partition by vac.location order by vac.location,vac.new_date_column)/dea.population)*100
from portfolioproject.coviddeaths as dea
join portfolioproject.covidvaccins as vac
	on  dea.location = vac.location
	and dea.new_date_column = vac.new_date_column
where dea.continent not in ('');

select * from percentpopulationvaccinated;


-- Create Views to store data for later visualizations




