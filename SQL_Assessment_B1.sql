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
select * from Production.Product
select * from 

--I. Find all the employees whose salary is more than the average salary

--J. Display country region code, group average sales quota based on territory id

--k. Find the average age of male and female

--L. Which product is purchased more? (purchase order details)

--M. Check for sales person details which are working in Stores (find the sales person ID)

--N. display the product name and product price and count of product cost revised (productcost history)

--O. check the department having more salary revision


