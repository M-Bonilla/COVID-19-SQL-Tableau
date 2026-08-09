/*
=====================================================================
Project: COVID-19 Data Exploration 
Author: Megan Bonilla Cerdas 
DataBase: PorfolioProject
SQL SERVER 
=====================================================================

Descripction:
This project explores COVID-19 data using SQL Server. 
This objective is to analyze infection rates, death rates, 
vaccination progress, and practice SQL concepts such as:

- Joins
- Aggregate Functions
- Window Functions
- CTE
- Temporary Tables
- Views

Dataset:
Our World in Data COVID Dataset
=====================================================================
*/

/*-------------------------------------------------------------------
1. Initial Data Exploration
-------------------------------------------------------------------*/

--Preview the COVID deaths dataset
Select *
From dbo.CovidDeaths
Where continent is not null 
Order by 3,4 
  

/*-------------------------------------------------------------------
2. Data Selection
-------------------------------------------------------------------*/
--Select columns required for the analysis  

Select	Location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population 
From dbo.CovidDeaths
Order by 1,2 

 
/*-------------------------------------------------------------------
3. Infection Analysis
-------------------------------------------------------------------*/
--Looking at Total Cases vs Total Deaths 
--Calculate the percentage of deaths among confirmed cases in Costa Rica.
Select	Location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths / total_cases)*100 AS DeathPercentage
From dbo.CovidDeaths
Where location = 'Costa Rica'
Order by 1,2 


--Looking at Total Cases vs Population 
--Calculate the percentage of the population infected in Costa Rica.
Select	Location, 
		date, 
		population, 
		total_cases, 
		(total_cases / population)*100 AS PercentPopulationInfetcted
From dbo.CovidDeaths
Where location = 'Costa Rica'
Order by 1,2 


--Identify countries with the highest infection rate relative to population.
Select	Location, 
		population, 
		MAX (total_cases) AS HighestInfectionCount, 
		MAX((total_cases / population))*100 AS PercentPopulationInfetcted
From dbo.CovidDeaths
Where continent is not null 
Group by Location, population
Order by PercentPopulationInfetcted desc 


/*-------------------------------------------------------------------
4. Mortality Analysis 
-------------------------------------------------------------------*/
--Showing Countries with Highest Death Count per Population 
Select	Location, 
		MAX (Cast (total_deaths as INT)) AS HighestDeathCount
From dbo.CovidDeaths
Where continent is not null 
Group by Location
Order by HighestDeathCount desc 


--Let's break things down by continent 
--Showing continents with highest death count per population 
Select	continent, 
		MAX (Cast (total_deaths as INT)) AS HighestDeathCount
From dbo.CovidDeaths
Where continent is not null 
Group by continent
Order by HighestDeathCount desc 


/*-------------------------------------------------------------------
5. Global Statistics 
-------------------------------------------------------------------*/
--GLOBAL NUMBERS 
Select	SUM(new_cases) AS Total_Cases, 
		SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathPercentage
From dbo.CovidDeaths
Where continent is not null 
Order by 1,2 


--Per day 
Select	date,
		SUM(new_cases) AS Total_Cases, 
		SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathPercentage
From dbo.CovidDeaths
Where continent is not null 
Group by date 
Order by 1,2 


/*-------------------------------------------------------------------
6. Vaccination Analysis
-------------------------------------------------------------------*/
Select * 
from CovidVaccinations

--Looking at Total Population vs Vaccinations 
Select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM (CONVERT(int, new_vaccinations )) OVER (Partition by dea.location
		Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths AS dea
Join CovidVaccinations AS vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3 


/*-------------------------------------------------------------------
7. Common Table Expression (CTE)
-------------------------------------------------------------------*/
--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
Select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM (CONVERT(int, new_vaccinations )) OVER (Partition by dea.location
		Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths AS dea
Join CovidVaccinations AS vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population) * 100 AS Percentagee
From PopvsVac


/*-------------------------------------------------------------------
8. Temporary Table
-------------------------------------------------------------------*/
--TEMP TABLE 
--Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar (250),
	location nvarchar(250),
	date datetime, 
	population numeric,
	new_vaccinations numeric, 
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM (CONVERT(int, new_vaccinations )) OVER (Partition by dea.location
		Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths AS dea
Join CovidVaccinations AS vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population) * 100 AS Percentagee
From #PercentPopulationVaccinated


/*-------------------------------------------------------------------
9. Create view 
-------------------------------------------------------------------*/
--Creating view to store data for later visualizations 
Create View PercentPopulationVaccinated AS
Select	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM (CONVERT(int, new_vaccinations )) OVER (Partition by dea.location
		Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths AS dea
Join CovidVaccinations AS vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

		MAX (total_cases) AS HighestInfectionCount, 
		MAX((total_cases / population))*100 AS PercentPopulationInfetcted
From dbo.CovidDeaths
Where continent is not null 
Group by Location, population
Order by PercentPopulationInfetcted desc 
