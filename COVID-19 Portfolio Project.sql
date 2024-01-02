--Data Source : Ourworldindata.org/covid-deaths
--check the tables to be used.

select *
from Portfolio_Project..covidDeath
order by 3,4;

Select * 
from Portfolio_Project..covidVaccinations
order by 3,4;

--Get the columns that are necessary for our project.

Select continent,location,date,population,total_cases,new_cases,total_deaths,new_deaths
from Portfolio_Project..covidDeath
order by 2,3;

--let's get the percentage of death compared to the population.

Select location,date,population,total_cases,new_cases,total_deaths,new_deaths,(total_deaths/population)*100 as total_death_percentage
from Portfolio_Project..covidDeath
order by 1,2;

--The Total_death_percentage daily in Canada.

Select location,date,population,total_cases,new_cases,total_deaths,new_deaths,(total_deaths/population)*100 as total_death_percentage
from Portfolio_Project..covidDeath
where location = 'Canada'
order by 1,2;

--The percentage_of_the_Population_infected daily in Canada.

Select location,date,population,total_cases,new_cases,total_deaths,new_deaths,(total_cases/population)*100 as percentage_of_population_infected
from Portfolio_Project..covidDeath
where location = 'Canada'
order by 1,2;

--Find the countries with the highest infection rate.

Select location,max(total_cases)as highest_infection_count
from Portfolio_Project..covidDeath
where continent is not null
group by location
order by highest_infection_count desc;

--Find the countries with the lowest infection rate.

Select location,max(total_cases)as highest_infection_count
from Portfolio_Project..covidDeath
where continent is not null
group by location
order by highest_infection_count asc;

--Find the countries with the highest infection rate compared to its population

Select location,population,max(total_cases)as highest_infection_count, max((total_cases/population))*100 as percentage_of_population_infected
from Portfolio_Project..covidDeath
where continent is not null
group by location,population
order by percentage_of_population_infected desc;

--Find the countries with the lowest infection rate compared to its population

Select location,population,max(total_cases)as highest_infection_count, max((total_cases/population))*100 as percentage_of_population_infected
from Portfolio_Project..covidDeath
where continent is not null
group by location,population
order by percentage_of_population_infected asc;  

--Let's find the  top 10 countries with the highest death count.

Select top 10 location,population, max(total_deaths)as total_death_count,count(*) as count
from Portfolio_Project..covidDeath
where continent is not null
group by location, population
order by total_death_count desc ; 


--find the 10 countries with the lowest death count.

Select top 10 location,population, max(total_deaths)as total_death_count,count(*) as count
from Portfolio_Project..covidDeath
where  continent is not null
group by location, population 
order by total_death_count asc ; 

--Let's look at the data continent-wise.

Select location, max(total_deaths)as total_death_count
from Portfolio_Project..covidDeath
where  continent is  null
group by location 
order by  total_death_count desc ; 

--Find the total death, total cases and death percentage across the world.

Select sum(new_cases) as "total cases" , sum(cast (new_deaths as int)) as "total deaths"  
from Portfolio_Project..covidDeath
where continent is not null;

--Bring in the second table : covidvaccinations.

Select * 
from Portfolio_Project..covidVaccinations
order by 3,4;

--let's join the two tables together.

Select * 
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
on Codeath.location = CoVacc.location
and Codeath.date = CoVacc.date;

--let's grab some data form the newly created table.

Select Codeath.continent, Codeath.location, Codeath.date,Codeath.total_deaths, Codeath.population, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
on Codeath.location = CoVacc.location
and Codeath.date = CoVacc.date
where Codeath.continent is not null
order by 1,2,3;

--Find the daily count/day of people vaccinated, new vaccinatons and moving count of people Vaccinated. 

Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations,
sum(cast(CoVacc.people_vaccinated as float))  over (partition by Codeath.location order by Codeath.location,Codeath.date ) as Moving_count_of_people_Vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date
where Codeath.continent is not null
order by 2,3;

--Working with the Moving_count_of_people_vaccinated, let's look at the people vaccinated in details.
--let use Common Table Expression(CTE).

With PopDeath_PopVaCC (continent, location, date, population,total_deaths ,total_vaccination, people_vaccinated,people_fully_vaccinated, new_vaccinations,Moving_count_of_people_Vaccinated )
as
(
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations,
sum(cast(CoVacc.people_vaccinated as float))  over (partition by Codeath.location order by Codeath.location,Codeath.date ) as Moving_count_of_people_Vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date
where Codeath.continent is not null
)
Select *
from PopDeath_PopVaCC

--Now we can work with the Moving_count_of_people_Vaccinated.
--calculated the percentage of the population that was vaccinated using the CTE.

With PopDeath_PopVaCC (continent, location, date, population, total_vaccination, people_vaccinated,people_fully_vaccinated, new_vaccinations,Moving_count_of_people_Vaccinated )
as
(
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations,
sum(cast(CoVacc.people_vaccinated as float))  over (partition by Codeath.location order by Codeath.location,Codeath.date ) as Moving_count_of_people_Vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date
where Codeath.continent is not null
)
Select *, (total_Vaccination/population)*100 as "%_of_people_Vaccinated"
from PopDeath_PopVaCC
                                  
--calculated the percentage of the population that was  fully_vaccinated using the CTE.

With PopDeath_PopVaCC (continent, location, date, population,total_deaths, total_vaccination, people_vaccinated,people_fully_vaccinated, new_vaccinations,Moving_count_of_people_Vaccinated )
as
(
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations,
sum(cast(CoVacc.people_vaccinated as float))  over (partition by Codeath.location order by Codeath.location,Codeath.date ) as Moving_count_of_people_Vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date
--where Codeath.continent is not null
)
Select *, (people_fully_Vaccinated/population)*100 as "%_of_people_Vaccinated"
from PopDeath_PopVaCC
order by 1,2

-- the percentage of the population that was  fully_vaccinated  in Canada using the CTE.

With PopDeath_PopVaCC (continent, location, date, population,total_deaths, total_vaccination, people_vaccinated,people_fully_vaccinated, new_vaccinations,Moving_count_of_people_Vaccinated )
as
(
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations,
sum(cast(CoVacc.people_vaccinated as float))  over (partition by Codeath.location order by Codeath.location,Codeath.date ) as Moving_count_of_people_Vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date
--where Codeath.continent is not null
)
Select *, (people_fully_Vaccinated/population)*100 as "%_of_people_Vaccinated"
from PopDeath_PopVaCC
where location = 'Canada'
order by 1,2;

--Creating Temp Tables

Create Table  "Percentage of people Vaccinated"
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
people_fully_vaccinated numeric,
Moving_count_of_people_Vaccinated numeric
)

Create Table  Percentage_of_total_deaths
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_deaths numeric,
total_deaths numeric,
New_vaccinations numeric,
people_fully_vaccinated numeric
)
Insert into Percentage_of_total_deaths
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, Codeath.new_deaths, CoVacc.new_vaccinations,CoVacc.people_fully_vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date;

Insert into "Percentage of people Vaccinated"
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date

--check Temp tables

select * 
from Percentage_of_total_deaths

--check Temp tables

select * 
from "Percentage of people vaccinated"

--we can alter the table.

Drop if exits Percentage_of_total_deaths
Create Table  Percentage_of_total_deaths
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_deaths numeric,
total_deaths numeric,
New_vaccinations numeric,
people_fully_vaccinated numeric
);
Insert into Percentage_of_total_deaths
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, Codeath.new_deaths, CoVacc.new_vaccinations,CoVacc.people_fully_vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date;
   
--Create a Views

Create view Moving_count_of_people_Vaccinated as
Select Codeath.continent, Codeath.location, Codeath.date, Codeath.population,Codeath.total_deaths, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations,
sum(cast(CoVacc.people_vaccinated as float))  over (partition by Codeath.location order by Codeath.location,Codeath.date ) as Moving_count_of_people_Vaccinated
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
   on Codeath.location = CoVacc.location
   and Codeath.date = CoVacc.date
where Codeath.continent is not null 


Create view my_covid_data as
Select Codeath.continent, Codeath.location, Codeath.date,Codeath.total_deaths, Codeath.population, CoVacc.total_vaccinations, CoVacc.people_vaccinated, CoVacc.people_fully_vaccinated, CoVacc.new_vaccinations
from Portfolio_Project..covidDeath as Codeath
join Portfolio_Project..covidVaccinations as CoVacc
on Codeath.location = CoVacc.location
and Codeath.date = CoVacc.date
where Codeath.continent is not null;

--check if the view was created.

select *
from my_covid_data;