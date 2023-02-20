
Select *
FROM [PORTFOLIO].[dbo].[CovidDeaths]
Where continent is not null
order by 3,4

--Select *
--FROM [PORTFOLIO].[dbo].[CovidVaccinations]
--order by 3,4

--select data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PORTFOLIO..CovidDeaths
order by 1,2

--looking at the total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From PORTFOLIO..CovidDeaths
Where location like 'Germany'
order by 1,2

--looking at total cases vs population
Select Location, date, population, total_cases, (total_cases/population)*100 as cases_percentage
From PORTFOLIO..CovidDeaths
Where location like 'Germany'
order by 1,2

--looking at countries with highest infection rate compared with population
Select Location, Population, MAX(total_cases) as Highest_InfectionCount, MAX(total_cases/population)*100 as MaxInfected_percentage
From PORTFOLIO..CovidDeaths
Group by Location, Population
order by MaxInfected_percentage desc

Select Location, Population, date, MAX(total_cases) as Highest_InfectionCount, MAX(total_cases/population)*100 as MaxInfected_percentage
From PORTFOLIO..CovidDeaths
Group by Location, Population, date
order by MaxInfected_percentage desc

--looking at countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as Highest_DeathCount
From PORTFOLIO..CovidDeaths
Where continent is not null
Group by Location
order by Highest_DeathCount desc

--looking at continents with highest death count
Select location, MAX(cast(Total_deaths as int)) as Highest_DeathCount
From PORTFOLIO..CovidDeaths
Where continent is null
and location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 
'European union', 'Low income', 'international')
Group by location
order by Highest_DeathCount desc

--Global numbers
Select SUM(total_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage --total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PORTFOLIO..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PORTFOLIO..CovidDeaths dea
Join PORTFOLIO..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date dateTime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as Rolling_People_Vaccinated
FROM PORTFOLIO..CovidDeaths dea
Join PORTFOLIO..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select * (Rolling_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view to store data for visualization

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as Rolling_People_Vaccinated
FROM PORTFOLIO..CovidDeaths dea
Join PORTFOLIO..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From Percent_Population_Vaccinated

