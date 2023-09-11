select * from PortfolioProject.dbo.CovidDeaths where continent is not null order by 3,4
--select * from PortfolioProject.dbo.CovidVaccinations order by 3,4

--select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject.dbo.CovidDeaths order by 1,2

--total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage' 
from PortfolioProject.dbo.CovidDeaths
where location like '%states%' and  continent is not null
order by 1,2



--Total cases vs Percentages
-- Shows what percentage of population got covid
select location,date,total_cases,population, (total_cases/population)*100 as 'PercentPopulationInfected' 
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
select location,population,Max(total_cases) as 'Highest Infection Count',Max((total_cases/population))*100 as 'PercentPopulationInfected' 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

select location,Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--showing the continents with the highest death count

select continent,Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers

 select date,SUM(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, 
 Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage from PortfolioProject.dbo.CovidDeaths
 where continent is not null
 group by date
 order by 1,2


 select  SUM(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, 
 Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage from PortfolioProject.dbo.CovidDeaths
 where continent is not null
 --group by date
 order by 1,2


 -- joining two tables 

 select * from PortfolioProject.dbo.CovidDeaths dea Join PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date

 -- looking at total population vs vaccinations

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject.dbo.CovidDeaths dea Join PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3



 With PopvsVac (Continent, Location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
 as 
 ( select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject.dbo.CovidDeaths dea Join PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 )
 select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac


 -- temp table
 DROP Table if exists #PercentPopluationVaccinated
 Create Table #PercentPopluationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric)


 Insert into #PercentPopluationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject.dbo.CovidDeaths dea Join PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null

 select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopluationVaccinated
 

 -- creating view to store data for later visualizations

 create View PercentPopluationVaccinated as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 from PortfolioProject.dbo.CovidDeaths dea Join PortfolioProject.dbo.CovidVaccinations vac
 ON dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null