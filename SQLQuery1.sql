Select Location, date, total_cases, new_cases, total_deaths, population From PortfolioProject..CovidDeaths Where continent is not null Order By 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you are covid positive in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage From PortfolioProject..CovidDeaths Where continent is not null Order By 1,2

-- Total Cases vs Population
-- Shows what percentage of population was Covid Positive

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected From PortfolioProject..CovidDeaths Where continent is not null Order By 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected From PortfolioProject..CovidDeaths Where continent is not null Group By Location, population Order By PercentagePopulationInfected desc

--Breaking things down by continent
--Countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount From PortfolioProject..CovidDeaths Where continent is null Group By Location Order By TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage From PortfolioProject..CovidDeaths Where continent is not null Order By 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date WHERE dea.continent is not null Order By 2,3


-- Using CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date WHERE dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100  From PopvsVac


-- TEMP Table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date

Select *, (RollingPeopleVaccinated/Population)*100 From #PercentPopulationVaccinated

-- Creating View to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date Where dea.continent is not null

Select * From PercentPopulationVaccinated

