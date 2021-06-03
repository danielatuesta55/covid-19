--STEP 6
--Checking the data was properly imported into postgres
SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL; 
--STEP 6
--Checking the data was properly imported into postgres
SELECT * 
FROM covid_vaccinations
WHERE continent IS NOT NULL;
--STEP 7
-- From covid_deaths table I extracted the following columns (total_case, new_cases, total_deaths, population)
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
order by 1,2;

--STEP 8 Searching for total cases vs total deaths in all countries 
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
order by 1,2;

-- STEP 9 Selected a country using the WHERE clause in SQL
--Shows the likelyhood of dying if you contract covid in Colombia
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location like '%Colombia%'
order by 1,2;

--STEP 10
--Total cases vs population 
-- What percentage of population has gotten covid
SELECT location, date, population,  total_cases, (total_cases/population)*100 AS percentage_population_infected
FROM covid_deaths
WHERE location like '%Colombia%'
order by 1,2;

-- STEP 11
-- Countries with highest infection rate compared to population 
SELECT location,  population,  MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percentage_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
--WHERE location like '%Colombia%'
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

--STEP 12
-- Countries with the highest death count per population 
SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

--STEP 13
-- Displaying highest death count per country
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC;


--STEP 14
--Showing the continents with the highest death count per population 
SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

--STEP 15 
-- Getting the global numbers
SELECT date, SUM(new_Cases) AS total_cases, SUM(new_deaths) AS total_deaths , SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2;

--STEP 16
-- Getting total cases in the world 
SELECT SUM(new_Cases) AS total_cases, SUM(new_deaths) AS total_deaths , SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--STEP 17 
-- Joining the two tabels togheter (deaths and vaccination)
SELECT *
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;
ORDER BY 1,2,3
-- STEP 18
-- Looking at the total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--STEP 19 
-- Looking daily increment in data totals for every location regarding vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_daily
FROM covid_deaths dea
JOIN covid_vaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--STEP 20 
-- Creating a table with the previouse query to then get the total daily vaccinated population percent

DROP TABLE IF EXISTS percentage_population_vaccinated

CREATE TABLE percentage_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_daily_vaccinated  
FROM covid_deaths dea
JOIN covid_vaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (total_daily_vaccinated/population)*100 AS total_population_vaccinated
FROM percentage_population_vaccinated;

-- STEP 21
-- Creating a view for later vizualization  
CREATE VIEW percentage_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_daily_vaccinated  
FROM covid_deaths dea
JOIN covid_vaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (total_daily_vaccinated/population)*100 AS total_population_vaccinated
FROM percentage_population_vaccinated;

-- Step 22
-- Creating the tables to use in tableu
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM covid_deaths
--Where location like '%states%'
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1,2;

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM covid_deaths
--Where location like '%states%'
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc;


-- 3.

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4.


SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
--Where location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc;
