Select *
From PorifolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PorifolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using


Select location, date, total_cases,new_cases, total_deaths, population
From PorifolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(convert(float,total_deaths)/Nullif(convert(float,total_cases),0))*100 as Deathpercentage
From PorifolioProject..CovidDeaths
where location like '%state%'and total_cases is not null and total_deaths is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, total_cases, Population,(convert(float,total_cases)/Nullif(convert(float,population),0))*100 as Deathpercentage
From PorifolioProject..CovidDeaths
where location like '%state%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location, Population,max(total_cases)as HighestInflectionCount,Max(convert(float,total_cases)/Nullif(convert(float,population),0))*100 as PercentPopulationinflected
From PorifolioProject..CovidDeaths
--where location like '%state%'
group by location,population
order by PercentPopulationinflected desc

--Showing Countrues with Highest Death Count Per Population
Select location,max(cast(total_deaths as int)) as HighestDeathsCount
From PorifolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location,population
order by HighestDeathsCount desc

--Let's break thing down by continent

Select continent,max(cast(total_deaths as int)) as HighestDeathsCount
From PorifolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by HighestDeathsCount desc


--Global Numbers
 


--Looking ar Total population vs Vaccination

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over ( partition by dea.location order by dea.location,dea.date)as cummulativefequency
From PorifolioProject..CovidDeaths dea
join  PorifolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
and dea.location is not null and dea.date is not null and vac.new_vaccinations is not null
order by 2,3


--Use CTE

With PopvsVac ( Continent,Location,Date,population,New_vaccination, cummulative)
as(

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over ( partition by dea.location order by dea.location,dea.date)as cummulativefequency
From PorifolioProject..CovidDeaths dea
join  PorifolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
and dea.location is not null and dea.date is not null and vac.new_vaccinations is not null
)
Select *,( cummulative/population)*100 as percentage
from PopvsVac
order by 2,3


--Temp table
Drop table if exists #PercentagePopulationVaccinated 
Create Table #PercentagePopulationVaccinated
(Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinaton numeric,
percentage numeric)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over ( partition by dea.location order by dea.location,dea.date)as cummulativefequency
From PorifolioProject..CovidDeaths dea
join  PorifolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
and dea.location is not null and dea.date is not null and vac.new_vaccinations is not null


Select *,(Percentage/population)*100
from #PercentagePopulationVaccinated
 


 --Creating view to store data for later visulization

 Create View PercentPopulationVaccinated as

 Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over ( partition by dea.location order by dea.location,dea.date)as cummulativefequency
From PorifolioProject..CovidDeaths dea
join  PorifolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
and dea.location is not null and dea.date is not null and vac.new_vaccinations is not null
--order by 1,2


Select* 
from PercentPopulationVaccinated