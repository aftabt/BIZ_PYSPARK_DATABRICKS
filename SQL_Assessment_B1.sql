--A. Find first 20 employees who joined very early in the company
select top 20 * from HumanResources.Employee
order by HireDate

--B. Find all employees name, job title, card details whose credit card expired in the month 9 and year as 2009
select p.FirstName, p.LastName, e.JobTitle, c.CreditCardID, c.CardNumber,  c.CardType, c.ExpMonth, c.ExpYear
from HumanResources.Employee e, Person.Person p, Sales.CreditCard c, Sales.PersonCreditCard pc
where (e.BusinessEntityID = p.BusinessEntityID and e.BusinessEntityID = pc.BusinessEntityID
and pc.CreditCardID = c.CreditCardID);

--C. Find the store address and contact number based on tables store and Business entity check if any other table is required.
select s.Name,CONCAT_WS(' ',a.AddressLine1, a.AddressLine2, a.City,a.PostalCode) [Address],
(select p.PhoneNumber from Person.PersonPhone p where p.BusinessEntityID = s.BusinessEntityID) Cont_number
from Person.Address a, Sales.Store s, Person.BusinessEntityAddress b
where b.AddressID = a.AddressID and b.BusinessEntityID = s.BusinessEntityID

--D. check if any employee from job candidate table is having any payment revisions
select * from HumanResources.JobCandidate
select * from HumanResources.EmployeePayHistory

select j.BusinessEntityID, Revisions
from (select distinct BusinessEntityID,
count(BusinessEntityID) over (partition by BusinessEntityID) Revisions
from HumanResources.EmployeePayHistory) t, HumanResources.JobCandidate j
where t.BusinessEntityID = j.BusinessEntityID

--E. check colour wise standard cost
select distinct Color,
avg(StandardCost) over (partition by color) Std_Cost
from Production.Product
order by Std_Cost

--F. Which product is purchased more? (purchase order details)
select * from Production.Product
select * from Purchasing.PurchaseOrderDetail

select p.ProductID, p.Name, t.order_qty
from(
select distinct ProductID,
sum(OrderQty) over (partition by productid) order_qty
from Purchasing.PurchaseOrderDetail) t, Production.Product p
where t.ProductID = p.ProductID
order by order_qty desc

--G. Find the total values for line total product having maximum order
select * from Production.Product
select * from Purchasing.PurchaseOrderDetail

select distinct ProductID,
sum(LineTotal) over (partition by productid) tot_linetotal,
sum(OrderQty) over (partition by productid) ord_qty
from Purchasing.PurchaseOrderDetail
order by ord_qty desc

--H. Which product is the oldest product as on the date (refer the product sell start date)
select ProductID,Name,SellStartDate 
from Production.Product
order by SellStartDate;

--I. Find all the employees whose salary is more than the average salary
select * from HumanResources.EmployeePayHistory

select distinct e.BusinessEntityID, p.FirstName, p.LastName, 
(select avg(rate) from HumanResources.EmployeePayHistory) avg_salary 
from HumanResources.Employee e,
Person.Person p
where e.BusinessEntityID = p.BusinessEntityID
and e.BusinessEntityID in 
	(select BusinessEntityID 
	from HumanResources.EmployeePayHistory 
	where rate >(select avg(rate) 
				from HumanResources.EmployeePayHistory))

--J. Display country region code, group average sales quota based on territory id
select * from Sales.SalesTerritory;
select * from Sales.SalesPerson;

select distinct st.TerritoryID,st.CountryRegionCode,st.[Group],
avg(sp.salesquota) over (partition by sp.territoryid) as avg_salequota
from Sales.SalesTerritory as st,
Sales.SalesPerson as sp
where st.TerritoryID = sp.TerritoryID;

--k. Find the average age of male and female
select * from HumanResources.Employee

select gender,
avg(DATEDIFF(year,BirthDate,HireDate)) as avg_age
from HumanResources.Employee
group by Gender;

--L. Which product is purchased more? (purchase order details)
select * from Purchasing.PurchaseOrderDetail

select ProductID,sum(orderqty) as total_ordqty
from Purchasing.PurchaseOrderDetail
group by ProductID
order by total_ordqty desc;

--M. Check for sales person details which are working in Stores (find the sales person ID)
select * from sales.SalesPerson
select distinct Name from Sales.Store

select distinct s.[Name],p.FirstName
from sales.Store as s,
Sales.SalesPerson as sp,
Person.Person as p
where s.SalesPersonID=sp.BusinessEntityID
and p.BusinessEntityID = sp.BusinessEntityID

--N. display the product name and product price and count of product cost revised (productcost history)
select * from Production.ProductCostHistory
select * from Production.Product;
select * from Production.ProductListPriceHistory;
select * from Production.TransactionHistory;

select pp.Name,th.ActualCost,count(pch.ProductID) as prod_cnt
from Production.Product as pp,
Production.ProductCostHistory as pch,
Production.TransactionHistory as th
where pp.ProductID = pch.ProductID
and th.ProductID = pp.ProductID
group by pp.name,th.ActualCost
having count(pch.ProductID) > 1

--O. check the department having more salary revision
select * from HumanResources.EmployeePayHistory;
select * from HumanResources.EmployeeDepartmentHistory;
select * from HumanResources.Department;

select  edh.DepartmentID,d.Name,
count(eph.payfrequency) as payfreq
from HumanResources.EmployeePayHistory as eph,
HumanResources.EmployeeDepartmentHistory as edh,
HumanResources.Department as d
where eph.BusinessEntityID = edh.BusinessEntityID
and edh.DepartmentID = d.DepartmentID
group by edh.DepartmentID,d.Name
having count(eph.payfrequency)>1

