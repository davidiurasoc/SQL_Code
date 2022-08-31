-- Selecting CovidDeaths Table

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4




-- Selecting CovidVaccinations Table

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4




-- Select Data that we are going to be using 

SELECT location,  date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 




-- Looking at Total Cases vs Total Deaths

SELECT location,  date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE  location like '%states%'
and continent is not null
ORDER BY 1,2 




-- Looking at the Total Cases vs Population

SELECT location,  date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE  location like '%gary%'
and continent is not null
ORDER BY 1,2 




-- Looking at countries  with highest   infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE  location like '%gary%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc




-- Showing countries with highest deathcount per population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE  location like '%gary%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc




-- Lets break things down to continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE  location like '%gary%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc




-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE  location like '%gary%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc




-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercenatge
FROM PortfolioProject..CovidDeaths
-- WHERE  location like '%gary%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2





---
--- Another table - JOIN
---





-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3




-- USE CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.population is not null
-- AND dea.location like '%gary%'
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / population) * 100 as PopulationVaccinatedPercentage
FROM PopvsVac




-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.population is not null
-- AND dea.location like '%gary%'
-- ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated / population) * 100 as PopulationVaccinatedPercentage
FROM #PercentPopulationVaccinated




-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.population is not null
-- ORDER BY 2, 3
SELECT *
FROM PercentPopulationVaccinated