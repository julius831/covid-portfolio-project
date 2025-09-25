SELECT * FROM portfolio.`covid 19 deaths`
order by 3,4;

-- SELECT * 
-- FROM portfolio.`covidvaccinations`
-- order by 3,4;

-- select the data we are going to use

SELECT 
 location , date , total_cases , new_cases , total_deaths , population
FROM portfolio.`covid 19 deaths`
order by 1,2;

-- look at total cases vs  total deaths
SELECT 
 location , date , total_cases ,  total_deaths , (total_deaths/total_cases)*100 as deathpercentage
FROM portfolio.`covid 19 deaths`
order by 1,2;

-- showing likelyhood of dying when you contact covid 19 in Africa

SELECT 
 location , date , total_cases ,  total_deaths , (total_deaths/total_cases)*100 as deathpercentage
FROM portfolio.`covid 19 deaths`
where location like '%africa%'
order by 1,2;

-- analyzing total_cases vs total_population
-- show % population on covid

SELECT 
 location , date , total_cases ,  population , (total_cases/population)*100 as deathpercentage
FROM portfolio.`covid 19 deaths`
where location like '%africa%'
order by 1,2;

-- looking at countries with high infection rate compared to population 

select
location , population , max(total_cases)  as highestinfectioncount , max((total_cases/population))*100 as percentagepopulationinfected
FROM portfolio.`covid 19 deaths`
where location like '%africa%'
group by population,location
order by highestinfectioncount desc ;
 
 -- countries with higher death count
 -- continent with highest death rate
 
select
continent , max(total_deaths ) as totaldeathcount
FROM portfolio.`covid 19 deaths`
-- where location like '%africa%'
where continent is not null
group by continent
order by totaldeathcount desc; 

-- lets check the covidvaccination table 
 -- and join with coviddeath
 
 select*
 FROM portfolio.`covid 19 deaths` dea
 join portfolio.covidvaccinations  covi
 on dea.date = covi.date
 and covi.location =dea.location; 
 
 -- looking into totalpopulation vs vaccination
 
 SELECT
  dea.continent,
  dea.date,
  dea.location,
  dea.population,
  covi.new_vaccinations,
  SUM(covi.new_vaccinations ) 
      OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS cumulative_vaccinations
FROM portfolio.`covid 19 deaths` dea
JOIN portfolio.covidvaccinations covi
  ON dea.date = covi.date
 AND covi.location = dea.location
WHERE dea.continent IS NOT NULL;
 
-- devide  cumulative_vaccinations with the population* 100 to get percentage
 -- use cte
 
 WITH newvalue AS (
  SELECT
    dea.date,
    dea.population,
    dea.location,
    dea.continent,
    covi.new_vaccinations,
    SUM(covi.new_vaccinations) 
      OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
  FROM portfolio.`covid 19 deaths` dea
  JOIN portfolio.covidvaccinations covi
    ON dea.date = covi.date
   AND dea.location = covi.location
)
SELECT *
FROM newvalue
WHERE continent IS NOT NULL
ORDER BY date, location;

-- percentage of vaccination  to population

WITH newvalue AS (
  SELECT
    dea.date,
    dea.population,
    dea.location,
    dea.continent,
    covi.new_vaccinations,
    SUM(covi.new_vaccinations) 
      OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
  FROM portfolio.`covid 19 deaths` dea
  JOIN portfolio.covidvaccinations covi
    ON dea.date = covi.date
   AND dea.location = covi.location
)
SELECT
  date,
  population,
  location,
  continent,
  new_vaccinations,
  cumulative_vaccinations,
  (cumulative_vaccinations / population * 100) AS vaccination_percentage
FROM newvalue
WHERE continent IS NOT NULL
ORDER BY date, location;

-- create view for later data analyzation
create view percenatagevaccinationpopulation as
 SELECT
  dea.date,
  dea.population,
  dea.location,
  dea.continent,
  covi.new_vaccinations,
  SUM(covi.new_vaccinations) 
      OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations,
  (SUM(covi.new_vaccinations) 
      OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population * 100) 
      AS vaccination_percentage
FROM portfolio.`covid 19 deaths` dea
JOIN portfolio.covidvaccinations covi
  ON dea.date = covi.date
 AND dea.location = covi.location
WHERE dea.continent IS NOT NULL;

-- check if the view was created

select* 
 from
 percenatagevaccinationpopulation;