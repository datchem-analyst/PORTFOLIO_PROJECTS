----SQL QUERY FOR COVID_DEATHS DATA EXPLORATION

SELECT *
FROM PortFolioProject..CovidDeaths
ORDER BY 3,4


SELECT *
FROM PortFolioProject..CovidVaccinations
ORDER BY 3,4

----DATA SELECTION

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortFolioProject..CovidDeaths
ORDER BY 1,2


----PERCENTAGE OF PEOPLE WHO DIED IN NIGERIA AND U.S.A FROM COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Covid_Death_Percentage
FROM PortFolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Covid_Death_Percentage
FROM PortFolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2


----PERCENTAGE OF COVID PATIENTS AMONG THE POPULATION IN NIGERIA AND U.S.A

SELECT location, date, population, total_cases, (total_cases/population)*100 as Covid_Patients_Percentage
FROM PortFolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 as Covid_Patients_Percentage
FROM PortFolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


----COUNTRIES WITH HIGHEST RATE OF COVID INFECTION AMONG THE POPULATION

SELECT location, population, MAX(total_cases) as Highest_Infection_Rate, MAX((total_cases/population))*100 as Covid_Infection_Percentage
FROM PortFolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 desc


----COUNTIRES WITH THE HIGHEST DEATH RATE PER POPULATION

SELECT location, population, MAX(CAST(total_deaths as int)) as Death_Rate_Per_Countries
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 desc



----CONTINENT WITH THE HIGHEST DEATH RATE PER POPULATION

SELECT location, MAX(CAST(total_deaths as int)) as Death_Rate_Per_Continent
FROM PortFolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 desc


----GLOBAL NUMBERS
----Percentage of people that died out of the new_cases of COvid per Day

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as  Percentage_Of_Deaths_Per_Day
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 desc

----Total Number of People that died in the Countries and their percentage

SELECT location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as  Total_Percentage_Of_Deaths
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
group by location
ORDER BY 3 desc

----Total number of deaths in the world

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as  Total_Percentage_Of_Deaths
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



----SQL QUERY FOR COVID_VACCINATIONS DATA EXPLORATION
----INNER JOIN

SELECT *
FROM PortFolioProject..CovidDeaths DEA
JOIN PortFolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date

----DATA SELECTION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM PortFolioProject..CovidDeaths DEA
JOIN PortFolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3


----TOTAL NUMBER OF INFECTED COVID PATIENTS VACCINATED

SELECT DEA.continent, DEA.location, DEA.population,DEA.date, DEA.total_cases, VAC.total_vaccinations
FROM PortFolioProject..CovidDeaths DEA
JOIN PortFolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null
order by 1,2


----SQL QUERY SHOWING THE ADDITION OF PEOPLE VACCINATED PER DAY


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


----TOTAL NUMBER OF PEOPLE VACCINATED PER COUNTRIES AND THE PERCENTAGE
--CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


----CREATING TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- CREATION OF VIEWS FOR VISUALIZATION

CREATE VIEW Percent_Population_Vaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


CREATE VIEW NIGERIA_DEATH_RATE AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Covid_Death_Percentage
FROM PortFolioProject..CovidDeaths
WHERE location like '%Nigeria%'

CREATE VIEW HIGHEST_INFECTION_RATE AS
SELECT location, population, MAX(total_cases) as Highest_Infection_Rate, MAX((total_cases/population))*100 as Covid_Infection_Percentage
FROM PortFolioProject..CovidDeaths
GROUP BY location, population


CREATE VIEW PEOPLE_VACCINATED AS
SELECT DEA.continent, DEA.location, DEA.population,DEA.date, DEA.total_cases, VAC.total_vaccinations
FROM PortFolioProject..CovidDeaths DEA
JOIN PortFolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null


