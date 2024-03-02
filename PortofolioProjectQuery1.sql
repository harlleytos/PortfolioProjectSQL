select * 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4 

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4 

-- Select data that we are going to be using  (do not keep in portfolio project)
 

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2 

-- Looking at total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null and location like '%nigeria%'
order by 1,2

-- looking at the total case vs population
-- shows what percentage of population got covid
select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
--where location like '%nigeria%'
order by 1,2


-- looking at countries with highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
--where location like '%nigeria%'
group by location, population
order by PercentPopulationInfected desc



-- showing the countries with the highest death count per population 

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
where continent is not null
--where location like '%nigeria%'
group by location, population
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT




-- showing the continent with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths 
where continent is null
--where location like '%nigeria%'
group by location
order by TotalDeathCount desc 


-- GLOBAL NUMBERS 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null 
--and 
--location like '%nigeria%'
--Group by date
order by 1,2 


--looking at total population vs vaccination 

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int) /* or convert(vac.new_vaccination, int)*/) OVER (Partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths   dea
JOIN  PortfolioProject..covidvaccinations vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3  


-- USE CTE 

With PopvsVac(Continent, location, date, population, RollingPeopleVaccinated, new_vaccinations)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int) /* or convert(vac.new_vaccination, int)*/) OVER (Partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths   dea
JOIN  PortfolioProject..covidvaccinations vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac 



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int) /* or convert(vac.new_vaccination, int)*/) OVER (Partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths   dea
JOIN  PortfolioProject..covidvaccinations vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated  


-- Create View to store data for latar visualization

create view PercentPopulationVaccinated as 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int) /* or convert(vac.new_vaccination, int)*/) OVER (Partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths   dea
JOIN  PortfolioProject..covidvaccinations vac
     ON dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

 
 select * 
 from PercentPopulationVaccinated