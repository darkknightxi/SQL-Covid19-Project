/*SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4 */

/*SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4*/

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
--Likelihood of dying if infected with covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location = 'India'
ORDER BY 1,2

--Total Cases vs Population
--Shows what percent of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is not Null --removes locations like asia, world, north america etc. which  are not really countries
ORDER BY 1,2

--Countries with highest infection rate

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as InfectionRate
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is not Null 
GROUP BY location, population
ORDER BY 4 desc

--Highest death count per population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is not Null
GROUP BY location
ORDER BY 2 desc

--Breaking things down by continent

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is not Null
GROUP BY continent
ORDER BY 2 desc

--Death count per population of continents

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is not Null
GROUP BY continent
ORDER BY 2 desc

-- Global Numbers

SELECT sum(new_cases)as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent is Not Null
ORDER BY 1,2


--Joining the two tables

SELECT *
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date

--Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.date) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not NULL and d.location = 'India'
ORDER BY 2,3


-- use CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not NULL and d.location = 'India'
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- use temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not NULL and d.location = 'India'
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating Views to store data for later visualisations

Create View PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not NULL --and d.location = 'India'
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
