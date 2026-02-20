create database sales_project;
use sales_project;

-- drop table customers;
-- drop table products;
-- drop table orders;

-- customer table
create table customers (
customer_id int primary key ,customer_name varchar(50),city varchar(30)
);

-- product table
create table products (
product_id int auto_increment primary key,product_name varchar(50),category varchar(30),unit_price int
);

-- order table
create table orders (
order_id int primary key,order_date date,customer_id int,product_id int,quantity int,
payment_mode varchar(20),
foreign key (customer_id) references customers(customer_id),
foreign key (product_id) references products(product_id)
);

-- Insert Customers
insert into customers (customer_id, customer_name, city)
select distinct CustomerID, CustomerName, City
from raw_sales_data;

-- Insert Products
insert into products (product_name,category,unit_price)
select distinct Product,Category,UnitPrice
from raw_sales_data;

-- Insert Orders
insert into orders (order_id,order_date,customer_id,product_id,quantity,payment_mode)
select s.OrderID,s.OrderDate,s.CustomerID,p.product_id,s.Quantity,s.PaymentMode
from raw_sales_data s
join products p
on s.Product = p.product_name
and s.UnitPrice = p.unit_price;

-- view all orders
select * from orders;

-- Total Orders
select count(*) as total_orders from orders;

-- Complete Sales Report
select
o.order_id,o.order_date,c.customer_name,c.city,
p.product_name,p.category,o.quantity,p.unit_price,
(o.quantity * p.unit_price) AS total_amount,
o.payment_mode
from orders o
join customers c on o.customer_id = c.customer_id
join products p on o.product_id = p.product_id;
       
-- Business Analysis

-- Total Sales Amount
select sum(o.quantity*p.unit_price) as Total_Sales
from orders o
join products p on o.product_id = p.product_id;

-- Sales by Category
select p.category, sum(o.quantity*p.unit_price) as  category_sales
from orders o
join products p on o.product_id = p.product_id
group by p.category;

-- Top 5 Customers by Sales
select c.customer_name, sum(o.quantity*p.unit_price) as total_spent
from orders o 
join customers c on o.customer_id = c.customer_id
join products p on o.product_id = p.product_id
group by c.customer_name
order by total_spent desc
limit 5;

-- Customers with Above-Average Purchase
select customer_name
from customers	
where customer_id in (
select customer_id 
from orders o
join products p on o.product_id = p.product_id
group by customer_id
having sum(o.quantity*p.unit_price) > (select avg(quantity*unit_price) from orders o2
join products p2 on o2.product_id = p2.product_id)
);

-- creating view
create view sales_summary as
select
o.order_id,c.customer_name,product_name,
o.quantity,(o.quantity * p.unit_price) as total_amount
from orders o
join customers c on o.customer_id = c.customer_id
join products p on o.product_id = p.product_id;

select * from sales_summary;

-- Indexing (Performance)
create index idx_order_date on orders(order_date);
create index idx_customer_id on orders(customer_id);

-- Stored Procedure
DELIMITER //
create procedure GetSalesByCity(in city_name varchar(30))
begin
    select
        c.city,
        SUM(o.quantity * p.unit_price) as city_sales
    from orders o
    join customers c on o.customer_id = c.customer_id
    join products p on o.product_id = p.product_id
    where c.city = city_name
    group by c.city;
end //
DELIMITER ;

call GetSalesByCity('Delhi');













