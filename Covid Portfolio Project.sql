use Porfolio1;

select
	DATA_TYPE,
	COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
where table_name = 'CovidDeaths$';

select *
from Porfolio1..CovidDeaths$
where continent is not null
order by 3,4

select *
from Porfolio1..CovidVaccinations$
order by 3,4


--Data I am going to be using
select location, date, total_cases, new_cases, total_deaths, population
from Porfolio1..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Porfolio1..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths (specifically) in the united kingdom
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Porfolio1..CovidDeaths$
where location like 'United k%'
order by 1,2


-- looking at total cases vs Population
-- showing percentage of population in the UK that got covid
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageInfection
from Porfolio1..CovidDeaths$
where location like 'United k%'
order by 1,2


-- looking at the countries that have the highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PopulationPercentageInfection
from Porfolio1..CovidDeaths$
--where location like 'United k%'
group by Location, population
order by PopulationPercentageInfection desc


-- showing the countries with the highest death count per population
select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PopulationPercentageInfection
from Porfolio1..CovidDeaths$
--where location like 'United k%'
group by Location, population
order by PopulationPercentageInfection desc

--checking the total amount of deaths in each location
select Location, date, max(cast(total_deaths as int)) as TotalDeaths
from Porfolio1..CovidDeaths$
--where location like 'United k%'
where continent is not null
group by Location, date
order by TotalDeaths desc


-- showing entire continents vs totaldeaths
select Location, max(cast(total_deaths as int)) as TotalDeaths
from Porfolio1..CovidDeaths$
--where location like 'United k%'
where continent is null
group by Location
order by TotalDeaths desc


--showing continents with the highest death counts per population
select continent, max(cast(total_deaths as int)) as TotalDeaths
from Porfolio1..CovidDeaths$
--where location like 'United k%'
where continent is not null
group by continent
order by TotalDeaths desc

-- GLOBAL NUMBERS (calculating the number of the total cases, total deaths, and percentage accross the world)
select date, sum(new_cases)as summedNewCases, sum(cast(new_deaths as int)) as summedDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Porfolio1..CovidDeaths$
--where location like 'united k%'
where continent is not null
group by date
order by 1,2

--overall, across the world 
select sum(new_cases)as summedNewCases, sum(cast(new_deaths as int)) as summedDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Porfolio1..CovidDeaths$
--where location like 'united k%'
where continent is not null
--group by date
order by 1,2


--using a join to check
select *
from Porfolio1..CovidDeaths$ dea
join Porfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollinPeopleVaccinated
from Porfolio1..CovidDeaths$ dea
join Porfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollinPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Porfolio1..CovidDeaths$ dea
join Porfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollinPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Porfolio1..CovidDeaths$ dea
join Porfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating a view to store the total cases vs the total deaths specifically in the United Kingdom

create view TotalCasesVsTotalDeaths_UK as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Porfolio1..CovidDeaths$
where location like 'United k%'
--order by 1,2


--creating view to store data for later visualisations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollinPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Porfolio1..CovidDeaths$ dea
join Porfolio1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated