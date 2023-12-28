SELECT * FROM CovidDeaths
WHERE total_deaths is NULL
SELECT * FROM dbo.CovidVaccinations

sp_help coviddeaths

SELECT DISTINCT(Location), Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE total_deaths is not null
ORDER BY 1

SELECT DISTINCT(Location)
FROM CovidDeaths
ORDER BY location

-- Looking at the Total cases vs Total Deaths

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 Death_Percentage
FROM CovidDeaths
--WHERE location LIKE '%India%'
ORDER BY 1 

-- Looking at the Total cases vs Population

SELECT Location, Date, total_cases, population, (total_cases/population)*100 PercentageOfPoluationWhoHadCovid
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY PercentageOfPoluationWhoHadCovid DESC

-- Country having highest infection rate compared to populuation

SELECT Location, population, MAX(total_cases) HighestInfectionCount, (MAX(total_cases)/population)*100 Percentpopulationinfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY Percentpopulationinfected DESC

--Countries with highest death count per population

SELECT Location, MAX(total_deaths) TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continent with highest death count per population

SELECT continent, MAX(total_deaths) TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers by date

SELECT Date, SUM(new_cases) Total_cases, SUM(new_deaths) Total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent is not Null
GROUP BY date
ORDER BY date

-- Total number of cases all over the globe
SELECT SUM(new_cases) Total_cases, SUM(new_deaths) Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent is not null

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
WHERE dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USING CTE

WITH PopVsVac 
(Continent, Location, Data, Population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated / Population ) * 100 PercentPPLVaccinated
FROM PopVsVac
ORDER BY PercentPPLVaccinated DESC

--Temp Table

DROP TABLE IF EXISTS #Percentpeoplevaccinated
Create table #Percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO #Percentpeoplevaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated / Population ) * 100 PercentPPLVaccinated
FROM #Percentpeoplevaccinated 

-- Views

CREATE VIEW PercentPolulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPolulationVaccinated