
SELECT *
FROM Covidproject2..CovidDeaths
ORDER BY 3,4

--SELECT THE DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covidproject2..CovidDeaths
ORDER BY 1,2

--Total cases vs total deaths = The likelihood of dying if you contract covid per country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathsPercentage
FROM Covidproject2..CovidDeaths
--WHERE location like '%kingdom%'
ORDER BY 1,2

--total cases vs population = percentage of people who contracted covid per country

SELECT location, date, population, total_cases, (total_cases/population)*100 as Percentageofpopulationinfected
FROM Covidproject2..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2


--Countries with highest infection rate vs population
SELECT location, population, MAX(total_cases) as HighestInfectioncount, MAX((total_cases/population))*100 as PercentageofHighestInfectioncount
FROM Covidproject2..CovidDeaths
--WHERE location like '%kingdom%'
GROUP BY location, population
ORDER BY PercentageofHighestInfectioncount desc


--Countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM Covidproject2..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not NULL
GROUP BY location
ORDER BY totaldeathcount desc



-- Continent with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as totaldeathcount
FROM Covidproject2..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY totaldeathcount desc

--Global numbers
SELECT SUM(new_cases) as totalNewcases, SUM(cast(new_deaths as int)) as totalNEWdeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Percentageofnewdeaths
FROM Covidproject2..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not NULL
--GROUP BY continent
ORDER BY 1,2


--SELECT *
--FROM Covidproject2..CovidVaccination
--ORDER BY 3,4

--Total population vs new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covidproject2..CovidVaccination vac
JOIN Covidproject2..CovidDeaths dea
    ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not NULL
--and vac.new_vaccinations is not NULL
ORDER BY 1,2,3

--SET ANSI_WARNINGS OFF
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPleVacs
FROM Covidproject2..CovidDeaths dea
JOIN Covidproject2..CovidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
and vac.new_vaccinations is not null
ORDER BY 2,3

--Using CTE - Percentage of perople Vaccinated by Location
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPPleVacs)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPleVacs
FROM Covidproject2..CovidDeaths dea
JOIN Covidproject2..CovidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
and vac.new_vaccinations is not null
)
SELECT *, (RollingPPleVacs/Population)*100
FROM PopvsVac


--Temp tabele -  %population

Drop Table if exists #PercentageofPeopleVaccinated 
Create Table #PercentageofPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPPleVacs numeric
)
Insert into #PercentageofPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPleVacs
FROM Covidproject2..CovidDeaths dea
JOIN Covidproject2..CovidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--and vac.new_vaccinations is not null

SELECT *, (RollingPPleVacs/Population)*100
FROM #PercentageofPeopleVaccinated

--Creating view to store data for visualizations

Create View PercentageofPeopleVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPPleVacs
FROM Covidproject2..CovidDeaths dea
JOIN Covidproject2..CovidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
and vac.new_vaccinations is not null

SELECT *
FROM PercentageofPeopleVaccinated
