SELECT *
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE continent is not null
ORDER BY 3,4

----Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE continent is not null
ORDER BY 1,2

--To get the % of deaths per country
Select Location, date, total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE continent is not null
ORDER BY 1,2

--Select country for specific death percentage
Select Location, date, total_cases,total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE location like '%Albania%'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid

Select Location, date, total_cases,population, (cast(total_cases as decimal))/(cast(population as decimal))*100 as PercentPopulationInfected
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE location like '%states%'
ORDER BY 1,2

--Look at countries with highest infection rate per population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((cast(total_cases as decimal))/(cast(population as decimal)))*100 as PercentPopulationInfected
FROM Portfolio_Project_Covid..CovidDeaths1
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing the countries with the highest death count per population

Select Location, MAX(CAST (total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths1
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Breaking things down by continent

--Showing continents with the highest death count

Select continent, MAX(CAST (total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project_Covid..CovidDeaths1
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

--Total new cases/deaths per day by date

Select date, SUM(new_cases) AS new_cases, 
SUM(Cast(new_deaths AS int)) AS new_deaths --SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total new cases Vs Deaths globally by date
Select date, SUM(new_cases) AS total_cases, 
SUM(Cast(new_deaths AS int)) AS new_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total Cases VS Total Deaths Globally

Select SUM(new_cases) AS total_cases, 
SUM(Cast(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project_Covid..CovidDeaths1
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Join tables for vaccinations and deaths

--Looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project_Covid..Covid_Vaccinations vac
JOIN Portfolio_Project_Covid..CovidDeaths1 dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Create CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project_Covid..Covid_Vaccinations vac
JOIN Portfolio_Project_Covid..CovidDeaths1 dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM PopvsVac


--Temp TABLE


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project_Covid..Covid_Vaccinations vac
JOIN Portfolio_Project_Covid..CovidDeaths1 dea
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project_Covid..Covid_Vaccinations vac
JOIN Portfolio_Project_Covid..CovidDeaths1 dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


--View table 
SELECT *
FROM #PercentPopulationVaccinated
