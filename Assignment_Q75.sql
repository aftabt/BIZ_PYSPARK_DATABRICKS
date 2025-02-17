use Assignment

create schema Person;

------------------------------------------------------------

/*
1.	Create a customer table having following column with suitable data type
Cust_id  (automatically incremented primary key)
Customer name (only characters must be there)
Aadhar card (unique per customer)
Mobile number (unique per customer)
Date of birth (check if the customer is having age more than15)
Address
Address type code (B- business, H- HOME, O-office and should not accept any other)
State code ( MH – Maharashtra, KA for Karnataka)
*/

create table Person.Customer (
    Cust_id int identity(1,1) primary key,
    Customer_Name varchar(100) not null check (Customer_Name not like '%[^a-zA-Z ]%'),
    Aadhar_Card char(12) unique not null,
    Mobile_Number char(10) unique not null,
    Date_of_Birth date not null check (datediff(year, Date_of_Birth, getdate()) > 15),
    Address varchar(255) not null,
    Address_Type char(1) not null check (Address_Type in ('B', 'H', 'O')),
    State_Code char(2) not null check (State_Code in ('MH', 'KA'))
);

-----------------------------------------------------------------------------------------------

/*
Create another table for Address type which is having
Address type code must accept only (B,H,O)
Address type  having the information as  (B- business, H- HOME, O-office)
*/

create table Person.Address (
    Address_Type char(1) primary key check (Address_Type in ('B', 'H', 'O')), 
    Address_Type_Description varchar(100) not null
);

insert into Person.Address (Address_Type, Address_Type_Description) values ('B', 'Business');
insert into Person.Address (Address_Type, Address_Type_Description) values ('H', 'Home');
insert into Person.Address (Address_Type, Address_Type_Description) values ('O', 'Office');

--------------------------------------------------------------------------------------------------

/*
Create table state_info having columns as  
State_id  primary unique
State name 
Country_code char(2)
*/

create table Person.StateInfo (
    State_Code char(2) primary key, 
    State_Name varchar(100) not null,
    Country_Code char(2) not null
);

---------------------------------------------------------------------------------

/*
Alter tables to link all tables based on suitable columns and foreign keys.
*/

-- link Customer with Address on Address_Type
alter table Person.Customer
add constraint fk_address_type
foreign key (Address_Type) references Person.Address(Address_Type);

-- link Customer with StateInfo on State_Code
alter table Person.Customer
add constraint fk_state_code
foreign key (State_Code) references Person.StateInfo(State_Code);

-------------------------------------------------------------------------------

/*
Change the column name from customer table customer name as c_name
*/

exec sp_rename 'Person.Customer.Customer_Name', 'C_Name', 'COLUMN';

-------------------------------------------------------------------------------
/*
Insert the suitable records into the respective tables
*/

insert into Person.StateInfo (State_Code, State_Name, Country_Code) values 
('MH', 'Maharashtra', 'IN'), 
('KA', 'Karnataka', 'IN');


insert into Person.Customer (Customer_Name, Aadhar_Card, Mobile_Number, Date_of_Birth, Address, Address_Type, State_Code) 
values 
('Aftab Tamboli', '123456789012', '9876543210', '2000-05-15', '123 Main St', 'B', 'MH'),
('Saee Kulkarni', '098765432109', '8765432109', '1998-07-25', '456 Park Ave', 'H', 'KA'),
('Gayatri Patil', '112233445566', '7654321098', '2005-01-10', '789 Elm St', 'O', 'MH');

----------------------------------------------------------------------------------------------------------------

/*
Change the data type of  country_code to varchar(3)
*/

alter table Person.StateInfo
alter column Country_Code varchar(3) not null;

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

--Based on adventurework solve the following questions

Use AdventureWorks2022;

/*
1.	 find the average currency rate conversion from USD to Algerian Dinar 
and Australian Doller 
*/

select * from Sales.Currency
select * from Sales.CurrencyRate

select * from Sales.Currency
where name = 'Algerian Dinar'
select * from Sales.CurrencyRate
where ToCurrencyCode = 'DZD'

select * from Sales.Currency
where name = 'Australian Dollar'
select * from Sales.CurrencyRate
where ToCurrencyCode = 'AUD'

select FromCurrencyCode, ToCurrencyCode, avg(AverageRate) Avg_Curr_Rate
from Sales.CurrencyRate
where FromCurrencyCode = 'USD' and ToCurrencyCode in ('DZD','AUD')
group by FromCurrencyCode, ToCurrencyCode

/*
2. Find the products having offer on it and display product name , 
afety Stock Level, Listprice,  and product model id, type of discount,  percentage of discount,  
offer start date and offer end date
*/

select * from Sales.SpecialOffer
select * from Sales.SpecialOfferProduct
select * from Production.Product

select p.Name, p.SafetyStockLevel, p.ListPrice, p.ProductModelID, so.Type, so.DiscountPct, so.StartDate, so.EndDate
from Sales.SpecialOffer so,
Sales.SpecialOfferProduct sop,
Production.Product p
where so.SpecialOfferID = sop.SpecialOfferID
and sop.ProductID = p.ProductID

/*
3.	 create  view to display Product name and Product review
*/

select * from Production.Product
select * from Production.ProductReview

create view ProductReviews as
SELECT p.Name ProductName, pr.Comments
FROM Production.Product AS p, Production.ProductReview AS pr
where p.ProductID = pr.ProductID;

/*
find out the vendor for product  paint, Adjustable Race and blade
*/

select * from Purchasing.ProductVendor
select * from Purchasing.Vendor
select * from Production.Product
where Name like '%Adjustable race%' or name like '%blade%' or name like '%Paint%'

select v.Name Vendor_Name, p.Name Product_Name
from Purchasing.Vendor v,
Production.Product p,
Purchasing.ProductVendor pv
where (v.BusinessEntityID = pv.BusinessEntityID and p.ProductID = pv.ProductID) and
(p.name like '%Paint%' or p.Name like '%Adjustable race%' or p.name like '%blade%' )

/*
5. find product details shipped through ZY - EXPRESS
*/

select * from Purchasing.PurchaseOrderDetail
select * from Purchasing.PurchaseOrderHeader
select * from Purchasing.ShipMethod
select * from Production.Product

select sm.Name Ship_Method, p.Name Prod_Name, COUNT(*) Count
from Purchasing.PurchaseOrderDetail pod,
Purchasing.PurchaseOrderHeader poh,
Purchasing.ShipMethod sm,
Production.Product p
where (pod.PurchaseOrderID = poh.PurchaseOrderID and
poh.ShipMethodID = sm.ShipMethodID and
pod.ProductID = p.ProductID) and
sm.ShipMethodID = 2
group by sm.Name, p.Name
order by Count desc

/*
6. find the tax amt for products where order date and ship date are on the same day
*/

select * from Sales.SalesTaxRate
select * from Production.Product
select * from sales.SalesOrderHeader
select * from Sales.SalesOrderDetail

select sod.ProductID, tr.TaxRate
from Sales.SalesOrderDetail sod, Sales.SalesOrderHeader soh, Sales.SalesTaxRate tr
where sod.SalesOrderID = soh.SalesOrderID and soh.OrderDate = soh.ShipDate;

/*
7. find the average days required to ship the product based on shipment type.
*/

select pm.Name ShipmentType, AVG(DATEDIFF(day, soh.OrderDate, soh.ShipDate)) AverageDaysToShip
from Sales.SalesOrderHeader soh, Purchasing.ShipMethod AS pm
where soh.ShipMethodID = pm.ShipMethodID
group by pm.Name;

/*
8.find the name of employees currently working in day shift
*/

select p.FirstName, p.LastName, s.ShiftID ,s.Name
from HumanResources.Employee e, HumanResources.EmployeeDepartmentHistory edh, HumanResources.Shift s, Person.Person p
where (e.BusinessEntityID = edh.BusinessEntityID and edh.ShiftID = s.ShiftID and e.BusinessEntityID = p.BusinessEntityID) 
and s.Name = 'Day' AND edh.EndDate IS NULL;

/*
9. based on product and product cost history find the name , service provider time and average Standardcost  
*/

select p.Name, pch.StartDate ServiceProviderTime, AVG(pch.StandardCost) AverageStandardCost
from Production.Product p, Production.ProductCostHistory pch
where p.ProductID = pch.ProductID
group by p.Name, pch.StartDate;

/*
10.	find products with average cost more than 500
*/

select p.Name, AVG(pch.StandardCost)
FROM Production.Product p, Production.ProductCostHistory pch
where p.ProductID = pch.ProductID
group by p.Name
having AVG(pch.StandardCost) > 500;

/*
11.	 find the employee who worked in multiple territory
*/

select e.BusinessEntityID, p.FirstName, p.LastName, st.TerritoryID, st.Name
from Sales.SalesTerritory st, Sales.SalesPerson sp, HumanResources.Employee e, Person.Person p
where st.TerritoryID = sp.TerritoryID and sp.BusinessEntityID = e.BusinessEntityID and p.BusinessEntityID = e.BusinessEntityID
group by e.BusinessEntityID, p.FirstName, p.LastName, st.TerritoryID, st.Name
having COUNT(st.TerritoryID) > 1;

/*
12. find out the Product model name,  product description for culture as Arabic
*/

select pm.Name ProductModelName, pmpdc.CultureID, pmpdc.ProductDescriptionID, pd.Description
from Production.ProductModel pm, Production.ProductModelProductDescriptionCulture pmpdc,Production.ProductDescription pd
where (pm.ProductModelID = pmpdc.ProductModelID and pmpdc.ProductDescriptionID = pd.ProductDescriptionID)
and pmpdc.CultureID = 'ar';

/*
13.	 Find first 20 employees who joined very early in the company
*/ 

select top 20 e.BusinessEntityID, p.FirstName, p.LastName, e.HireDate
FROM HumanResources.Employee e, Person.Person p
where p.BusinessEntityID = e.BusinessEntityID
order by HireDate;

/*
14.	Find most trending product based on sales and purchase.
*/

--sales
select p.Name ProductName, SUM(sod.OrderQty) TotalSales
FROM Production.Product AS p, Sales.SalesOrderDetail AS sod 
where p.ProductID = sod.ProductID
group by p.Name
order by TotalSales DESC;

--product
select p.Name AS ProductName, SUM(pod.OrderQty) AS TotalPurchases
from Production.Product AS p, Purchasing.PurchaseOrderDetail AS pod
where p.ProductID = pod.ProductID
group by p.Name
order by TotalPurchases DESC;

/*
15.	 display EMP name, territory name, saleslastyear salesquota and bonus
*/

select concat_ws(' ',p.FirstName, p.LastName) EMPName, 
       (select Name from Sales.SalesTerritory where TerritoryID = sp.TerritoryID) TerritoryName,
       sp.SalesLastYear, sp.SalesQuota, sp.Bonus
from Sales.SalesPerson sp, Person.Person p, HumanResources.Employee e 
where sp.BusinessEntityID = e.BusinessEntityID and p.BusinessEntityID = e.BusinessEntityID

/*
16. display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom
*/

select concat_ws(' ',p.FirstName, p.LastName) EMPName, 
       (select Name from Sales.SalesTerritory where TerritoryID = sp.TerritoryID AND Name IN ('Germany', 'United Kingdom')) TerritoryName,
       sp.SalesLastYear, sp.SalesQuota, sp.Bonus
from Sales.SalesPerson AS sp, Person.Person p, HumanResources.Employee AS e
where sp.BusinessEntityID = e.BusinessEntityID and p.BusinessEntityID = e.BusinessEntityID and
(sp.TerritoryID IN (SELECT TerritoryID FROM Sales.SalesTerritory WHERE Name IN ('Germany', 'United Kingdom')));

/*
17.	 Find all employees who worked in all North America territory
*/

select * from HumanResources.Employee
select * from Sales.SalesTerritory
select * from Sales.SalesTerritoryHistory

select CONCAT_WS(' ',p.FirstName, p.LastName) Fullname, st.[Group]
from Person.Person p,
HumanResources.Employee e,
Sales.SalesTerritory st,
Sales.SalesTerritoryHistory sth
where (e.BusinessEntityID = sth.BusinessEntityID and
sth.TerritoryID = st.TerritoryID and
p.BusinessEntityID = e.BusinessEntityID) and
st.[Group] = 'North America'

/*
18.	 find all products in the cart
*/

select p.*
from Production.Product p
where p.ProductID IN (select ProductID from Sales.ShoppingCartItem);

/*
19.	 find all the products with special offer
*/

select p.*
from Production.Product as p
where p.ProductID IN (select ProductID from Sales.SpecialOfferProduct);

/*
20.	 find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008
*/

select * from Sales.CreditCard

select p.FirstName, p.LastName, e.JobTitle, cc.CardNumber, cc.ExpMonth, cc.ExpYear
from HumanResources.Employee e, Sales.PersonCreditCard pcc, Sales.CreditCard cc, Person.Person p
where (e.BusinessEntityID = pcc.BusinessEntityID and pcc.CreditCardID = cc.CreditCardID and p.BusinessEntityID = e.BusinessEntityID)
and cc.ExpMonth <= 11 AND cc.ExpYear <= 2008;

/*
21.	 Find the employee whose payment might be revised  (Hint : Employee payment history)
*/

select * from HumanResources.EmployeePayHistory
select * from HumanResources.Employee

select BusinessEntityID, count(*)
from HumanResources.EmployeePayHistory 
group by BusinessEntityID
having count(*) > 1

select * from HumanResources.Employee
where BusinessEntityID not in (select BusinessEntityID
from HumanResources.EmployeePayHistory)


/*
22.	 Find total standard cost for the active Product. (Product cost history)
*/

select p.Name, SUM(pch.StandardCost) TotalStandardCost
from Production.Product p, Production.ProductCostHistory pch
where p.ProductID = pch.ProductID and p.DiscontinuedDate IS NULL
group by p.Name;

select p.Name, SUM(pch.StandardCost) TotalStandardCost
from Production.Product p, Production.ProductCostHistory pch
where p.ProductID = pch.ProductID and p.DiscontinuedDate IS NULL
group by p.Name;

/*
23.	Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type)
*/

select pe.BusinessEntityID, pe.FirstName, pe.LastName, a.AddressLine1, a.AddressLine2, a.City, 
       st.Name StateProvince, c.Name CountryRegion, at.Name AddressType
from Person.Person pe, Person.BusinessEntityAddress bea, Person.Address a, Person.StateProvince st,
Person.CountryRegion c, Person.AddressType at
where pe.BusinessEntityID = bea.BusinessEntityID and bea.AddressID = a.AddressID and a.StateProvinceID = st.StateProvinceID 
and st.CountryRegionCode = c.CountryRegionCode and bea.AddressTypeID = at.AddressTypeID;

/*
24.	 Find the name of employees working in group of North America territory
*/

select p.FirstName, p.LastName, st.Name, st.[Group]
FROM HumanResources.Employee e, Person.Person p, Sales.SalesPerson sp, Sales.SalesTerritory st
where p.BusinessEntityID = e.BusinessEntityID and e.BusinessEntityID = sp.BusinessEntityID and sp.TerritoryID = st.TerritoryID 
and st.[Group] = 'North America';

/*
25.	 Find the employee whose payment is revised for more than once                                  
*/

select eph.BusinessEntityID, p.FirstName, p.LastName, COUNT(RateChangeDate) Revisions
from HumanResources.EmployeePayHistory eph, Person.Person p
where eph.BusinessEntityID = p.BusinessEntityID
group by eph.BusinessEntityID, p.FirstName, p.LastName
having COUNT(RateChangeDate) > 1;

/*
26. display the personal details of  employee whose payment is revised for more than once.
*/

select e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle, COUNT(eph.RateChangeDate) Revisions
from HumanResources.Employee AS e, Person.Person p, HumanResources.EmployeePayHistory AS eph
where e.BusinessEntityID = eph.BusinessEntityID and e.BusinessEntityID = p.BusinessEntityID
group by e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle
having COUNT(eph.RateChangeDate) > 1;

/*
27.	Which shelf is having maximum quantity (product inventory)
*/

select Shelf, SUM(Quantity) TotalQuantity
from Production.ProductInventory
group by Shelf
order by TotalQuantity DESC

/*
28. Which shelf is using maximum bin (product inventory):
*/

select Shelf, COUNT(DISTINCT Bin) BinCount
from Production.ProductInventory
group by Shelf
order by BinCount DESC

/*
29. Which location is having minimum bin (product inventory):
*/

select LocationID, COUNT(DISTINCT Bin) BinCount
from Production.ProductInventory
group by LocationID
order by BinCount ASC

/*
30. Find out the product available in most of the locations (product inventory):
*/

select ProductID,COUNT(DISTINCT LocationID) LocationCount
from Production.ProductInventory
group by ProductID
order by LocationCount DESC

/*
31. Which sales order is having most order quantity
*/

select SalesOrderID, SUM(OrderQty) TotalOrderQty
from Sales.SalesOrderDetail
group by SalesOrderID
order by TotalOrderQty DESC

/*
33. Check if any employee from the job candidate table is having any payment revisions
*/

select jc.BusinessEntityID, 
(select CONCAT_WS(' ',FirstName, LastName) from Person.Person where BusinessEntityID = jc.BusinessEntityID) FullName
from HumanResources.JobCandidate jc
where exists (
    select 1 from HumanResources.EmployeePayHistory eph
    where eph.BusinessEntityID = jc.BusinessEntityID
);

/*
34.	check the department having more salary revision
*/

select d.Name AS DepartmentName, COUNT(eph.BusinessEntityID) RevisionCount
from HumanResources.Department d, HumanResources.EmployeeDepartmentHistory edh, HumanResources.EmployeePayHistory eph
where d.DepartmentID = edh.DepartmentID and edh.BusinessEntityID = eph.BusinessEntityID
group by d.Name
order by RevisionCount DESC

/*
35. Check the employee whose payment is not yet revised
*/

select e.BusinessEntityID, p.FirstName, p.LastName
from HumanResources.Employee e, HumanResources.EmployeePayHistory AS eph, Person.Person p
where (e.BusinessEntityID = eph.BusinessEntityID and p.BusinessEntityID = e.BusinessEntityID) and eph.BusinessEntityID IS NULL;

/*
36. Find the job title having more revised payments
*/

select e.JobTitle, COUNT(eph.BusinessEntityID) RevisionCount
from HumanResources.Employee e, HumanResources.EmployeePayHistory eph
where e.BusinessEntityID = eph.BusinessEntityID
group by e.JobTitle
order by RevisionCount DESC

/*
38.	 find the colour wise count of the product (tbl: product)
*/

select Color, COUNT(*) ProductCount
from Production.Product
group by Color;

/*
39. Find out the product which is not in a position to sell (hint: check the sell start and end date)
*/

select  ProductID, Name
from Production.Product
where SellEndDate IS NOT NULL AND SellEndDate < GETDATE();

/*
40.	  find the class wise, style wise average standard cost
*/

select Class, Style, AVG(StandardCost) AverageStandardCost
from Production.Product
group by Class, Style;

/*
41. Check color-wise standard cost:
*/

select Color, AVG(StandardCost) AverageStandardCost
from Production.Product
group by Color;

/*
42. Find the product line-wise standard cost
*/

select ProductLine, AVG(StandardCost) AverageStandardCost
from Production.Product
group by ProductLine;

/*
43. Find the state-wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince)
*/

select sp.Name State, str.TaxRate
from Sales.SalesTaxRate str, Person.StateProvince sp
where str.StateProvinceID = sp.StateProvinceID;

/*
44. Find the department-wise count of employees
*/

select d.Name DepartmentName, COUNT(e.BusinessEntityID) EmployeeCount
from HumanResources.Department d, HumanResources.EmployeeDepartmentHistory edh,HumanResources.Employee e
where d.DepartmentID = edh.DepartmentID and edh.BusinessEntityID = e.BusinessEntityID
group by d.Name;

/*
45. Find the department which is having more employees
*/

select d.Name DepartmentName, COUNT(e.BusinessEntityID) EmployeeCount
FROM HumanResources.Department d, HumanResources.EmployeeDepartmentHistory edh, HumanResources.Employee e
where d.DepartmentID = edh.DepartmentID and edh.BusinessEntityID = e.BusinessEntityID
group by d.[Name]
order by EmployeeCount DESC

/*
46. Find the job title having more employees
*/

select JobTitle, COUNT(BusinessEntityID) EmployeeCount
from HumanResources.Employee
group by JobTitle
order by EmployeeCount DESC

/*
47. Check if there is mass hiring of employees on a single day
*/

select HireDate, COUNT(*) HireCount
from HumanResources.Employee
group by HireDate
having COUNT(*) > 1;

/*
48. Which product is purchased more (purchase order details)
*/

select p.Name, SUM(pod.OrderQty) TotalPurchased
from Production.Product AS p, Purchasing.PurchaseOrderDetail AS pod
where p.ProductID = pod.ProductID
group by p.Name
order by TotalPurchased DESC

/*
49. Find the territory-wise customers count (hint: customer)
*/

select st.Name TerritoryName, COUNT(c.CustomerID) CustomerCount
from Sales.SalesTerritory st, Sales.Customer AS c 
where st.TerritoryID = c.TerritoryID
group by st.Name;

/*
50. Which territory is having more customers
*/

select st.Name TerritoryName, COUNT(c.CustomerID) CustomerCount
from Sales.SalesTerritory st, Sales.Customer c
where st.TerritoryID = c.TerritoryID
group by st.Name
order by CustomerCount DESC

/*
51. Which territory is having more stores
*/

select st.Name TerritoryName, COUNT(c.CustomerID) StoreCount
from Sales.SalesTerritory AS st, Sales.Customer AS c 
where st.TerritoryID = c.TerritoryID and c.StoreID IS NOT NULL
group by st.Name
order by StoreCount DESC

/*
52. Is there any person having more than one credit card
*/

select pe.FirstName, pe.LastName, COUNT(pcc.CreditCardID) CreditCardCount
from Sales.PersonCreditCard pcc, Person.Person pe
where pcc.BusinessEntityID = pe.BusinessEntityID
group by pe.FirstName, pe.LastName
having COUNT(pcc.CreditCardID) > 1;

/*
53. Find the product-wise sale price (sales order details)
*/

select p.Name ProductName, sod.UnitPrice SalePrice
FROM Sales.SalesOrderDetail sod, Production.Product p
where sod.ProductID = p.ProductID;

/*
54. Find the total values for line total product having maximum order
*/

select SalesOrderID, SUM(LineTotal) TotalValue
from Sales.SalesOrderDetail
group by SalesOrderID
order by SUM(OrderQty) DESC

/*
55.	Calculate the age of employees
*/

select e.BusinessEntityID, FirstName, LastName, 
       DATEDIFF(YEAR, BirthDate, GETDATE()) Age
from HumanResources.Employee e, Person.Person p
where e.BusinessEntityID = p.BusinessEntityID

/*
56. Calculate the year of experience of the employee based on hire date
*/

select e.BusinessEntityID, p.FirstName, p.LastName, 
       DATEDIFF(YEAR, HireDate, GETDATE()) YearsOfExperience
from HumanResources.Employee e, Person.Person p
where e.BusinessEntityID = p.BusinessEntityID;

/*
57. Find the age of employee at the time of joining
*/

select e.BusinessEntityID, FirstName, LastName, 
       DATEDIFF(YEAR, BirthDate, HireDate) AgeAtJoining
from HumanResources.Employee e, Person.Person p
where e.BusinessEntityID = p.BusinessEntityID;

/*
58. Find the average age of male and female
*/

select Gender, AVG(DATEDIFF(YEAR, BirthDate, GETDATE())) AverageAge
from HumanResources.Employee
group by Gender;

/*
59. Which product is the oldest product as on the date (refer the product sell start date)
*/

select Name
from Production.Product
order by SellStartDate 

/*
60. Display the product name, standard cost, and time duration for the same cost (Product cost history)
*/

select p.Name, pch.StandardCost, 
       DATEDIFF(DAY, pch.StartDate, pch.EndDate) Duration
from Production.Product p, Production.ProductCostHistory AS pch 
where p.ProductID = pch.ProductID;

/*
61. Find the purchase ID where shipment is done 1 month later of order date
*/

select PurchaseOrderID
from Purchasing.PurchaseOrderHeader
where DATEDIFF(MONTH, OrderDate, ShipDate) = 1;

/*
62. Find the sum of total due where shipment is done 1 month later of order date (Purchase order header)
*/

select SUM(TotalDue) SumTotalDue
from Purchasing.PurchaseOrderHeader
where DATEDIFF(MONTH, OrderDate, ShipDate) = 1;

/*
63. Find the average difference in due date and ship date based on online order flag
*/

select OnlineOrderFlag, AVG(DATEDIFF(DAY, DueDate, ShipDate)) AvgDifference
from Sales.SalesOrderHeader
group by OnlineOrderFlag;

/*
64. Display business entity id, marital status, gender, vacationhr, average vacation based on marital status
*/

select BusinessEntityID, MaritalStatus, Gender, VacationHours,
AVG(VacationHours) over (partition by MaritalStatus) AvgVacationBasedOnMaritalStatus
from HumanResources.Employee;

/*
65. Display business entity id, marital status, gender, vacationhr, 
average vacation based on gender
*/

select BusinessEntityID, MaritalStatus, Gender, VacationHours,
AVG(VacationHours) over (partition by Gender) AvgVacationBasedOnGender
from HumanResources.Employee;

/*
66. Display business entity id, marital status, gender, vacationhr, 
average vacation based on organizational level:
*/

select e.BusinessEntityID, e.MaritalStatus, e.Gender, e.VacationHours,
       AVG(e.VacationHours) over (partition by edh.OrganizationLevel) AvgVacationBasedOnOrgLevel
from HumanResources.Employee AS e, HumanResources.EmployeeDepartmentHistory AS edh 
where e.BusinessEntityID = edh.BusinessEntityID;

/*
67. Display entity id, hire date, department name and department-wise 
count of employees and count based on organizational level in each dept
*/

select e.BusinessEntityID, e.HireDate, d.Name DepartmentName,
COUNT(*) over (partition by d.Name) DeptEmployeeCount,
COUNT(*) over (partition by d.Name, edh.OrganizationLevel) OrgLevelEmployeeCount
from HumanResources.Employee e, HumanResources.EmployeeDepartmentHistory edh, HumanResources.Department d
where e.BusinessEntityID = edh.BusinessEntityID and edh.DepartmentID = d.DepartmentID;

/*
68. Display department name, average sick leave and sick leave per department
*/

select d.Name DepartmentName, e.SickLeaveHours,
       AVG(e.SickLeaveHours) over (partition by d.Name) AvgSickLeavePerDept
FROM HumanResources.Employee e, HumanResources.EmployeeDepartmentHistory edh, HumanResources.Department d
where e.BusinessEntityID = edh.BusinessEntityID and edh.DepartmentID = d.DepartmentID;

/*
69. Display the employee details first name, last name, with total count of 
various shifts done by the person and shifts count per department
*/

select p.FirstName, p.LastName,
COUNT(*) over (partition by e.BusinessEntityID) TotalShiftsDone,
COUNT(*) over (partition by d.Name) ShiftsCountPerDept
from HumanResources.Employee e, HumanResources.EmployeeDepartmentHistory edh,
HumanResources.Department d, HumanResources.Shift s, Person.Person p
where e.BusinessEntityID = edh.BusinessEntityID and edh.DepartmentID = d.DepartmentID 
and e.BusinessEntityID = p.BusinessEntityID and edh.ShiftID = s.ShiftID;

/*
70. Display country region code, group average sales quota based on territory id
*/

select st.CountryRegionCode, st.TerritoryID, sp.SalesQuota,
       AVG(sp.SalesQuota) over (partition by st.TerritoryID) AvgSalesQuota
from Sales.SalesPerson sp, Sales.SalesTerritory st
where sp.TerritoryID = st.TerritoryID;

/*
71. Display special offer description, category, and avg(discount pct) per the category
*/

select s.Description, s.Category, s.DiscountPct,
AVG(s.DiscountPct) over (partition by s.Category) AvgDiscountPct
from Sales.SpecialOffer s;

/*
72. Display special offer description, category, and avg(discount pct) per the month
*/

select s.Description, s.Category, s.DiscountPct, MONTH(s.StartDate) OfferMonth,
       AVG(s.DiscountPct) over (partition by MONTH(s.StartDate)) AvgDiscountPctPerMonth
from Sales.SpecialOffer s;

/*
73. Display special offer description, category, and avg(discount pct) per the year:
*/

select s.Description, s.Category, s.DiscountPct, YEAR(s.StartDate) OfferYear,
AVG(s.DiscountPct) over (partition by YEAR(s.StartDate)) AvgDiscountPctPerYear
from Sales.SpecialOffer s;

/*
74. Display special offer description, category, and avg(discount pct) per the type
*/

select s.Description, s.Category, s.DiscountPct, s.Type,
AVG(s.DiscountPct) over (partition by s.Type) AvgDiscountPctPerType
from Sales.SpecialOffer s;

/*
75. Using rank and dense rank, find territory-wise top sales person
*/

select st.Name AS TerritoryName, p.FirstName, p.LastName, sp.SalesYTD,
RANK() OVER (PARTITION BY st.TerritoryID ORDER BY sp.SalesYTD DESC) AS SalesRank,
DENSE_RANK() OVER (PARTITION BY st.TerritoryID ORDER BY sp.SalesYTD DESC) AS DenseSalesRank
FROM Sales.SalesPerson AS sp, HumanResources.Employee AS e, Sales.SalesTerritory AS st, Person.Person p
where sp.BusinessEntityID = e.BusinessEntityID and sp.TerritoryID = st.TerritoryID and e.BusinessEntityID = p.BusinessEntityID;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

----------














