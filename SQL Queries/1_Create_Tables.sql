USE ecommerce_analytics ;

CREATE TABLE Customers(
CustomerID	bigint,
FirstName varchar(30),
LastName varchar(30),
Date_of_Birth datetime,
City varchar(30),
State varchar(30),
Country varchar(30),
PostalCode bigint,
Phone bigint,
Email varchar(30),
DateEntered datetime);

CREATE TABLE Orders(
OrderID bigint,
CustomerID bigint, 
PaymentID bigint,
OrderDate date,
ShipperID bigint,
ShipDate date,
DeliveryDate date,
Total_order_amount bigint);


CREATE TABLE Category(
CategoryID bigint,
CategoryName varchar(30),
Active varchar(30));

CREATE TABLE OrderDetails(
OrderDetailID bigint,
OrderID	bigint, 
ProductID bigint,
Quantity bigint, 
SupplierID bigint) ;

CREATE TABLE Payments
(PaymentID bigint,
PaymentType varchar(30),
Allowed varchar(30));

CREATE TABLE Products
(
ProductID bigint,
Product	varchar(200),
Category_ID bigint,
Sub_Category varchar(200),
Brand varchar(200),
Sale_Price bigint,
Market_Price bigint,
Type varchar(200));


CREATE TABLE Shippers(
ShipperID bigint,
CompanyName	varchar(40), 
Phone bigint);


CREATE TABLE Suppliers(
SupplierID bigint,
CompanyName varchar(50),
City varchar(50),
State varchar(50),
PostalCode bigint,
Country	varchar(30),
Phone bigint,
Email varchar(30)
);