USE Covid19;

-- Checking the databases
SELECT *
FROM CovidDeaths
ORDER BY 3,4;

SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

-- Death Toll, Infection Count to date
SELECT 
	location,
	MAX(total_cases) AS total_cases, 
	MAX(total_deaths) AS total_deaths, 
	100.0*MAX(total_deaths)/MAX(total_cases) AS death_rate
FROM CovidDeaths
WHERE location ='World'
GROUP BY location;

-- Percentage of the population that is fully and partially vaccinated
SELECT TOP 1
	population,
	date,
	people_vaccinated AS ppl_vac,
	people_fully_vaccinated AS fully_vac
FROM CovidVaccinations
WHERE location = 'World'
ORDER BY date DESC;

--Total cases and deaths by continent
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths,
	(100.0*total_deaths/total_cases) AS death_rate,
	population
FROM CovidDeaths
WHERE continent IS NULL
ORDER BY location, date;

--Total cases and deaths by country
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	(100.0*total_deaths/total_cases) AS death_rate,
	population
FROM CovidDeaths
WHERE continent IS NOT NULL -- to exclude the tabulated numbers for continents
ORDER BY location, date;

-- Percentage of population infected over time
SELECT location, date, total_cases, population, (100.0*total_cases/population) AS PercentageInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Comparing infection rates of countries
SELECT 
	location, 
	population,
	MAX(total_cases) AS infection_count,  
	MAX(100.0*total_cases/population) AS infection_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Comparing death percentages of countries
SELECT 
	location, 
	MAX(total_deaths) AS HighestDeathCount, 
	population, 
	MAX(100.0*total_deaths/population) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage DESC;

-- GLOBAL CASES AND DEATH TOLLS
CREATE VIEW Global_Cases AS
SELECT
	a.date,
	SUM(a.new_cases) AS new_cases, 
	SUM(a.total_cases) AS cum_cases,
	SUM(a.new_deaths) AS new_deaths,
	SUM(a.total_deaths) AS cum_deaths,
	100.0*SUM(a.total_deaths)/SUM(a.total_cases) AS death_rate
FROM CovidDeaths a JOIN CovidVaccinations b 
	ON a.date=b.date
	AND a.location=b.location
WHERE a.continent IS NOT NULL
GROUP BY a.date;

-- Timeseries of Rolling Vaccinations by country
CREATE VIEW Vac_vs_Pop AS
SELECT 
	a.continent, 
	a.location, 
	a.date, 
	b.population, 
	a.new_vaccinations, 
	MAX(a.people_vaccinated) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS Rolling_Vaccinated,
	100.0*MAX(a.people_vaccinated) OVER (PARTITION BY a.location ORDER BY a.location, a.date)/a.population AS PercentageVaccinated
FROM CovidVaccinations a 
	JOIN CovidDeaths b
	ON a.location=b.location
	AND a.date=b.date
WHERE a.continent IS NOT NULL;