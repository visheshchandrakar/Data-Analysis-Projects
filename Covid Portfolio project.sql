Select *
From [potfolio project]..['CovidDeaths']
order by 3,4

--Select *
--From [potfolio project]..['CovidVaccination']
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [potfolio project]..['CovidDeaths']
order by 1,2


-- Looking at Total Cases vs Toatal Deaths
--Shows likelihood of dyinf you contract with covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From [potfolio project]..['CovidDeaths']
where location like '%india%'
order by 1,2

--Looking at  Total cases vs Population

Select Location, date, total_cases, population, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From [potfolio project]..['CovidDeaths']
--where location like '%india%'
order by 1,2

--Looking at countries the highest infection rate compared to population


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [potfolio project]..['CovidDeaths']
--Where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [potfolio project]..['CovidDeaths']
--Where location like '%india%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [potfolio project]..['CovidDeaths']
--Where location like '%india%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [potfolio project]..['CovidDeaths']
--Where location like '%india%'
Where continent is not null 
--Group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



-- USE CTE to perform Calculation on Partition By in previous query 

With PopvsVac (continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [potfolio project]..['CovidDeaths'] dea
Join [potfolio project]..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [potfolio project]..['CovidDeaths'] dea
Join [potfolio project]..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [potfolio project]..['CovidDeaths'] dea
Join [potfolio project]..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated


