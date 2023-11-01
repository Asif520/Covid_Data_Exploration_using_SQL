select * from CovidDeaths

select * from CovidVaccinations 

-- What we want to see

select location, date,total_cases,new_cases,total_deaths,new_deaths,population
from CovidDeaths
order by 1,2

--Total cases vs Total deaths by location

select location, sum(cast(new_cases as int)) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths
from CovidDeaths
where continent is not null
group by location
order by Total_deaths desc

--Total cases vs Total deaths by like

select location, sum(cast(new_cases as int)) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths
from CovidDeaths
where location like '%states%'
and continent is not null
group by location
order by Total_deaths desc

--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths
where location = 'Bangladesh'
and continent is not null
order by date,DeathPercentage


--Total case vs population

select location,max(population) as Population, sum(cast(new_cases as int)) as Total_Cases
from CovidDeaths
where continent is not null
group by location
order by location

--Shows what percentage of population infected with Covid of a country

select location, Population, sum(cast(new_cases as int)) as Total_Cases, ((sum(cast(new_cases as int)))/max(population)) *100 as Covid_Infected_Rate
from CovidDeaths
where continent is not null
and location = 'Bangladesh'
group by location,Population
order by Covid_Infected_Rate desc

--Total Death vs population

select location, max(population) as Population, sum(cast(new_deaths as int)) as Total_Deaths
from CovidDeaths
where continent is not null
group by location
order by location

--Shows what percentage of population died of covid of a country

select location,Population, sum(cast(new_deaths as int)) as Total_Deaths, ((sum(cast(new_deaths as int)))/max(population)) *100 as Covid_deaths_rate
from CovidDeaths
where continent is not null
and location = 'Bangladesh'
group by location,population
order by Covid_deaths_rate 


--Countries with Highest Infection Rate compared to Population

select location, population , max(total_cases) as Total_Infected_Cases, ((max(total_cases))/max(population)) *100 as Covid_Infected_Rate_Population
from CovidDeaths
where continent is not null
group by location, population
order by Covid_Infected_Rate_Population desc

--Countries with Highest Death Count per Population

select location , Population,  max(cast(total_deaths as int)) as Total_deaths, (max(cast(total_deaths as int))/population) *100 as Death_rate_population
from CovidDeaths
where continent is not null
group by location,Population
order by Total_deaths desc


--BREAKING THINGS DOWN BY CONTINENT

--Total Cases vs Total Deaths by Continent

select continent, sum(cast(new_cases as int)) as Total_Covid_Cases ,sum(cast(new_deaths as int)) as Total_deaths
from CovidDeaths
where continent is not null
group by continent
order by Total_deaths desc

--Global Numbers

select date , sum(cast(new_cases as int)) as Total_Cases , sum(cast(new_deaths as int)) as Total_Deaths, 
round(sum(cast(new_deaths as float))/sum(cast(new_cases as float)),2) as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- join two tables

select * 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Total Population vs Vaccinations

select dea.continent,dea.location,dea.Date, dea.population,  vac.new_vaccinations , 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2


--Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location,Date,population,new_vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent,dea.location,dea.Date, dea.population,  vac.new_vaccinations , 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
select *, (Rolling_People_Vaccinated/population)*100 as Vaccination_Rate from
PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #Population_Vaccinated
create table #Population_Vaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #Population_Vaccinated
select dea.continent,dea.location,dea.Date, dea.population,  vac.new_vaccinations , 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	
--where dea.continent is not null

select *, (Rolling_People_Vaccinated/population)*100 as Vaccination_Rate 
from #Population_Vaccinated


--Create a view to store data for visualization

Create view Percent_Population_Vaccinated as
select dea.continent,dea.location,dea.Date, dea.population,  vac.new_vaccinations , 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from Percent_Population_Vaccinated


