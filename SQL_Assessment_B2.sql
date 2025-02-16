--NAME: AFTAB TAMBOLI
--EMP ID: 06
--BATCH: 2


use AdventureWorks2022;
--A) Find employee having highest rate or highest pay frequency
select * from HumanResources.Employee
select * from HumanResources.EmployeePayHistory

select e.BusinessEntityID, e.NationalIDNumber, e.JobTitle, e.Gender, ep.Rate, ep.PayFrequency
from HumanResources.Employee e, HumanResources.EmployeePayHistory ep
where e.BusinessEntityID = ep.BusinessEntityID
order by Rate desc, PayFrequency desc


--B) Analyze the inventory based on the shelf wise count of the product and their quantity. 
select * from Production.ProductInventory

select ProductID, Shelf, Quantity,
count(*) over (partition by Shelf, Quantity) Count 
from Production.ProductInventory


--C) Find the personal details with address and address type
select * from Person.Person
select * from Person.Address
select * from Person.BusinessEntityAddress

select p.BusinessEntityID, CONCAT_WS(' ',FirstName, LastName) FullName,
CONCAT_WS(' ',AddressLine1,AddressLine2,City,PostalCode),
b.AddressTypeID
from Person.Person p, Person.Address a, Person.BusinessEntityAddress b
where p.BusinessEntityID = b.BusinessEntityID and b.AddressID = a.AddressID 


--D) Find the job title having more revised payments
select * from HumanResources.EmployeePayHistory

select JobTitle, COUNT(BusinessEntityID) no_of_revpay
from HumanResources.Employee
where BusinessEntityID in(
select BusinessEntityID
from HumanResources.EmployeePayHistory
group by BusinessEntityID
having COUNT(BusinessEntityID) > 1)
group by JobTitle
order by no_of_revpay desc


--E) Display special offer description, category and avg(discount pct) per the month
select * from Sales.SpecialOffer
select * from Sales.SpecialOfferProduct

select SpecialOfferID, Description, Category, StartDate, AVG(DiscountPct) Avg_disc_pct
from Sales.SpecialOffer
group by SpecialOfferID, Description, Category,StartDate
order by MONTH(StartDate)


--F) Display special offer description, category and avg(discount pct) per the Year
select SpecialOfferID, Description, Category, StartDate, AVG(DiscountPct) Avg_disc_pct
from Sales.SpecialOffer
group by SpecialOfferID, Description, Category,StartDate
order by Year(StartDate)


--G) Using rank and dense rand find territory wise top sales person
select * from sales.SalesTerritory
select * from Sales.SalesPerson

select sp.BusinessEntityID,
(select CONCAT_WS(' ', FirstName, LastName) from Person.Person p
where p.BusinessEntityID = sp.BusinessEntityID) Sales_Per_Name,
sp.TerritoryID, sp.SalesYTD,
rank() over (order by sp.SalesYTD desc) Sales,
DENSE_RANk() over (order by sp.SalesYTD desc) Sales
from Sales.SalesPerson sp, Sales.SalesTerritory st
group by sp.BusinessEntityID, sp.TerritoryID, sp.SalesYTD


--H) Calculate total years of experience of the employee and find out employees those who server for more than 20 years

--this query is to find total years of experience
select BusinessEntityID, 
(select CONCAT_WS(' ', FirstName, LastName) from Person.Person 
where BusinessEntityID = e.BusinessEntityID) Emp_Name ,
JobTitle,
DATEDIFF(YEAR, HireDate, GETDATE()) Total_Yrs_Exp
from HumanResources.Employee e

--this query is to find employees those who served for more than 20 years
select BusinessEntityID, 
(select CONCAT_WS(' ', FirstName, LastName) from Person.Person 
where BusinessEntityID = e.BusinessEntityID) Emp_Name ,
JobTitle,
DATEDIFF(YEAR, HireDate, GETDATE()) as Total_Yrs_Exp
from HumanResources.Employee e
where DATEDIFF(YEAR, HireDate, GETDATE()) > 20

--since there are no records found
--as a result, it implies there is no employees who served fro more than 20 years


--I. Find the employee who is having more vacations than the average vacation taken by all employees
select * from HumanResources.Employee

select BusinessEntityID,
(select CONCAT_WS(' ', FirstName, LastName) from Person.Person 
where BusinessEntityID = e.BusinessEntityID) FullName,
NationalIDNumber, JobTitle, Gender, VacationHours 
from HumanResources.Employee e
where VacationHours > (select avg(VacationHours)
from HumanResources.Employee)
order by VacationHours


--K) Find the department name  having more employees
select * from HumanResources.Employee
select * from HumanResources.EmployeeDepartmentHistory
select * from HumanResources.Department

select d.DepartmentID, d.Name, COUNT(*) Count
from HumanResources.Employee e, HumanResources.Department d, HumanResources.EmployeeDepartmentHistory ed
where  ed.BusinessEntityID = e.BusinessEntityID and ed.DepartmentID = d.DepartmentID
group by d.DepartmentID, d.Name
order by Count desc


--L) Is there any person having more than one credit card
select * from Sales.PersonCreditCard
select * from Sales.CreditCard

select BusinessEntityID, COUNT(CreditCardID) No_of_CC
from Sales.PersonCreditCard
group by BusinessEntityID
having COUNT(CreditCardID) > 1

--since there are no records found
--as a result, it implies that there are no person with more than 1 credit card


--M) Find how many subcategories are available per  product . (product sub category 
select * from Production.ProductSubcategory

select t.ProductCategoryID, sum(SubCat) No_of_SubCat
from
(select ProductCategoryID, Name, count(ProductSubcategoryID) SubCat
from Production.ProductSubcategory
group by ProductCategoryID, Name) t
group by t.ProductCategoryID

select Distinct ProductCategoryID,
count(ProductSubcategoryID) over (partition by productcategoryid)
from Production.ProductSubcategory


--N) Find total standard cost for the active Product where end date is not updated. (Product cost history)
select * from Production.ProductCostHistory

select ProductID, StartDate, EndDate, SUM(StandardCost) Total_Std_cost
from Production.ProductCostHistory
where EndDate is null
group by ProductID, StartDate, EndDate


--O. Which territory is having more customers (hint: customer)
select * from Sales.Customer

select TerritoryID, COUNT(CustomerID) No_of_Cust
from Sales.Customer
group by TerritoryID
order by No_of_Cust desc

---------------------------------------END----------------------------------------------