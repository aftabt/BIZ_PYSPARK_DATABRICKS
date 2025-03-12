-- Databricks notebook source
create database if not exists superstore_DB

-- COMMAND ----------

-- MAGIC %python
-- MAGIC store_df = spark.read.format("csv").option("header","true").option("inferschema","true")\
-- MAGIC                         .load(path = "dbfs:/FileStore/tables/Superstore.csv")
-- MAGIC
-- MAGIC store_df.display()

-- COMMAND ----------

-- MAGIC %python
-- MAGIC store_df = store_df.withColumn("Sales", store_df["Sales"].cast('double'))

-- COMMAND ----------

-- MAGIC %python
-- MAGIC store_df = store_df.withColumn("Quantity", store_df["Quantity"].cast('integer'))
-- MAGIC store_df = store_df.withColumn("Discount", store_df["Discount"].cast('double'))

-- COMMAND ----------

-- MAGIC %python
-- MAGIC store_df.printSchema()

-- COMMAND ----------

-- MAGIC %python
-- MAGIC store_df.dtypes

-- COMMAND ----------

-- MAGIC %python
-- MAGIC store_df.createGlobalTempView('storeview')

-- COMMAND ----------

select * from global_temp.storeview

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.fs.rm('dbfs:/user/hive/warehouse/superstore_db.db/supertable',recurse=True) 

-- COMMAND ----------

create table superstore_DB.SuperTable (
    no integer,
    order_id string,
    OrderDate date,
    ShipDate date,
    ShipMode string,
    CustomerID string,
    CustomerName string,
    Segment string,
    Country string,
    City string,
    State string,
    PostalCode integer,
    Region string,
    ProductID string,
    Category string,
    SubCategory string,
    ProductName string,
    Sales double,
    Quantity integer,
    Discount double,
    Profit double

)

-- COMMAND ----------

insert into superstore_DB.SuperTable
select * from global_temp.storeview

-- COMMAND ----------

select * from superstore_db.supertable

-- COMMAND ----------

select no from superstore_db.supertable

-- COMMAND ----------

select * from superstore_db.supertable

-- COMMAND ----------

select * from superstore_db.supertable
limit 40

-- COMMAND ----------

select * from superstore_db.supertable
order by no desc
limit 15

-- COMMAND ----------

select city, state, region, profit from superstore_db.supertable

-- COMMAND ----------

select shipmode, customerid, customername, segment, country from superstore_db.supertable
where no <= 1500 and no >= 1000;

-- COMMAND ----------

select profit, state, category, subcategory, region from superstore_db.supertable
where no in (1920 , 1940, 1945, 1980)

-- COMMAND ----------

DESCRIBE superstore_db.supertable

-- COMMAND ----------

select * from superstore_db.supertable
where month(OrderDate) = 06 and year(OrderDate) = 2014

-- COMMAND ----------

select month(orderdate) Months, avg(Profit) AvgProfit 
from superstore_db.supertable
group by Month(OrderDate)
order by Months

-- COMMAND ----------

select distinct month(orderdate) Months, 
avg(profit) over (partition by month(orderdate)) AvgProfit
from superstore_db.supertable

-- COMMAND ----------

select sum(sales) Sum_Sales from superstore_db.supertable

-- COMMAND ----------

select month(orderdate) Months, sum(Sales) SumSales
from superstore_db.supertable
group by Month(OrderDate)
order by Months

-- COMMAND ----------

select distinct month(orderdate) Months, 
sum(sales) over (partition by month(orderdate)) SumSales
from superstore_db.supertable

-- COMMAND ----------

select distinct Country, City, 
avg(profit) over (partition by Country, City) AvgProfit
from superstore_db.supertable

-- COMMAND ----------

select Country, City, avg(Profit) from superstore_db.supertable
group by Country, City

-- COMMAND ----------

-- MAGIC %python
-- MAGIC a = "select * from superstore_db.supertable where State= 'California'"
-- MAGIC df = spark.sql(a)

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df.show()

-- COMMAND ----------

select * from superstore_db.supertable
where State= 'California'

-- COMMAND ----------

select distinct Region, 
avg(profit) over (partition by Region) AvgProfit
from superstore_db.supertable

-- COMMAND ----------

select distinct ShipMode,
avg(Profit) over (partition by ShipMode) AvgProfit from superstore_db.supertable


-- COMMAND ----------

select * from superstore_db.supertable
where Profit <= 0

-- COMMAND ----------

-- MAGIC %python
-- MAGIC a = """select * from superstore_db.supertable
-- MAGIC where Profit <= 0"""
-- MAGIC df1 = spark.sql(a)
-- MAGIC df1.show()

-- COMMAND ----------

select distinct category, subcategory, 
sum(Sales) over (partition by category, subcategory) SumSales  
from superstore_db.supertable

-- COMMAND ----------

-- MAGIC %python
-- MAGIC b = """select * from superstore_db.supertable
-- MAGIC where Discount = 0"""
-- MAGIC df2 = spark.sql(b)
-- MAGIC df2.display()

-- COMMAND ----------

select * from superstore_db.supertable
where month(OrderDate) = 01 and year(OrderDate) = 2014
and month(shipdate) = 01 and year(shipdate) = 2014

-- COMMAND ----------

-- MAGIC %python
-- MAGIC c = """
-- MAGIC select * from superstore_db.supertable
-- MAGIC where month(OrderDate) = 01 and year(OrderDate) = 2014
-- MAGIC and month(shipdate) = 01 and year(shipdate) = 2014"""
-- MAGIC df3 = spark.sql(c)
-- MAGIC df3.display()

-- COMMAND ----------

select * from superstore_db.supertable
where Segment = 'Consumer'

-- COMMAND ----------

select *
from superstore_db.supertable
where State = 'Texas' and Category = 'Furniture'
