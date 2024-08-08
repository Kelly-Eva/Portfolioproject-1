SELECT *
FROM PortfolioProject1..CovidDeaths$
WHERE Continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinationSQL$

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths$
ORDER BY 1,2

--Looking at the Total cases vs Total Death
--This shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
WHERE location like '%Ita%'
ORDER BY 1,2

--Looking at the total cases vs Population 
--And showing what percentage of the poupulation got covid

SELECT location, date, Population, total_cases, (total_cases/Population)*100 AS Percentage_of_Population_Infected
FROM PortfolioProject1..CovidDeaths$
--WHERE location like '%Ita%'
ORDER BY 1,2

--Looking at countries with highest Infection rate compared to population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS Percentage_of_Population_Infected
FROM PortfolioProject1..CovidDeaths$
--WHERE location like '%Ita%'
GROUP BY Location, Population
ORDER BY Percentage_of_Population_Infected DESC

--Showing the Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--BREAKING THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE Continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths$
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths$
--WHERE location like '%Ita%' 
WHERE continent is not null
ORDER BY 1,2

SELECT date, SUM(new_cases), SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
--WHERE location like '%Ita%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
--WHERE location like '%Ita%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total cases per day
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths$
--WHERE location like '%Ita%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT *
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinationSQL$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinationSQL$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2

--OR USING CONVERT FXN

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinationSQL$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinationSQL$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac


--TEMP TABLE
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinationSQL$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating views to store data for later visualisations
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinationSQL$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated
