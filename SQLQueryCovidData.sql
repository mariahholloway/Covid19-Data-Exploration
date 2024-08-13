/*Select *
From PortfolioProject..CovidDeathss
Where continent is not null --gets rid of locations where it takes entire continent
Order By 3,4 */

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4 

-- Select Data   we are going to eb using 
--Select location,date,total_cases,new_cases,total_deaths,population
--From PortfolioProject..CovidDeathss
--Order by 1,2

--calculation -looking at the total cases vs the total deaths (% of who had it and passed)
-- 1st method cast chars in total death column as float integers uses NULLIF to avoid dividing by 0
-- second method is case when and if clause



SELECT location,date,total_deaths,total_cases , CAST(total_deaths AS float) /NULLIF(total_cases,0) *100 AS DeathPercentage
From PortfolioProject..CovidDeathss
Where location like '%states%' -- by countries in the world
Order by 1,2

-- looking at total cases vs population % of population has gotten covid 
SELECT location,date,population,total_cases , NULLIF(total_cases,0)/ CAST(population AS float) *100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeathss
Where location like '%states%' -- by countries in the world
and continent is not null 
Order by 1,2

--looks at highest infections rates by countries compared to population
--the highest total cases is represented by highest infection count 
-- about 30% of the usa population is/ were infected with covid
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX (NULLIF(total_cases,0))/ CAST(population AS float) *100 AS PercentagePopulationInfected
From PortfolioProject..CovidDeathss
Where continent is not null 
Group by location , Population
Order by PercentagePopulationInfected desc

/*LETS BREAK THINGS DOWN BY CONTINENTS (NOT QUITE RIGHT NUMBERS 
SELECT continent, MAX (CAST(total_deaths AS int)) as TotaldeathCount
From PortfolioProject..CovidDeathss  
GROUP BY CONTINENT HELPS
*/


-- SHOULD BE CORRECT NUMBER for total death count 
SELECT location, MAX (CAST(total_deaths AS int)) as TotaldeathCount
From PortfolioProject..CovidDeathss
Where (continent = '') --gets rid of locations where it takes entire continent
Group by location 
Order by TotaldeathCount desc


-- showing COUNTRIES with highest death count per population
SELECT location, MAX (CAST(total_deaths AS int)) as TotaldeathCount
From PortfolioProject..CovidDeathss
Where (continent != '') --gets rid of locations where it takes entire continent
Group by location 
Order by TotaldeathCount desc

/*continue to break down by continents showing continents with the HIGHEST death count per POPULATION */
SELECT continent, MAX (CAST(total_deaths AS int)) as TotaldeathCount
From PortfolioProject..CovidDeathss
Where (continent != '') --gets rid of locations where it takes entire continent
Group by continent 
Order by TotaldeathCount desc



-- NULLIF(OBJECT,0) helpes with Divide by zero error encountered.
--GLOBAL NUMBERS 
-- across the world death percent 2%
/*SELECT date, SUM(CAST (new_cases AS bigint))AS TotalCases , SUM(CAST (new_deaths AS bigint))as TotalDeaths , 
SUM(CAST (new_deaths AS bigint)) / (SUM(CAST (new_cases AS bigint))) * 100 as DeathPercentage
From PortfolioProject..CovidDeathss
Where (continent!='')
Group by date
Order by 1,2 */

Select * 
From PortfolioProject..CovidVaccinations

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathss dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathss dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathss dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathss dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
