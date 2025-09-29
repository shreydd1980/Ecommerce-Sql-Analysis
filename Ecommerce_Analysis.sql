
-- Displaying data from all the tables - 

SELECT * FROM customers ; 
SELECT * FROM orders; 
SELECT * FROM products;
SELECT * FROM orderdetails; 
SELECT * FROM category;
SELECT * FROM payments; 
SELECT * FROM shippers; 
SELECT * FROM suppliers;




-- Section 1: Customers

--- Customer details such as full name, email, and city are retrieved to build a foundation for customer segmentation and communication.

SELECT CONCAT(FirstName, ' ', LastName) 
AS Full_Name, Email, City 
FROM customers

--- Customer counts by country are calculated to evaluate geographic distribution and identify top-performing regions.
SELECT Country, COUNT(CustomerID) AS cnt 
FROM customers
GROUP BY Country 
ORDER BY cnt DESC;

--- The most recent customers are listed based on registration date to track new acquisitions.
SELECT CustomerID, FirstName, DateEntered 
FROM customers
ORDER BY DateEntered ASC;

--- Customers who have placed at least one order are identified to measure active user engagement.
SELECT c.CustomerID, c.FirstName, COUNT(o.OrderID) AS cnt 
FROM customers AS c 
JOIN orders AS o ON c.CustomerID = o.CustomerID 
GROUP BY c.CustomerID, c.FirstName
HAVING COUNT(o.OrderID) >= 1
ORDER BY cnt DESC;

--- Total spending per customer is calculated to spot high-value buyers who contribute most to revenue.
SELECT c.CustomerID, 
CONCAT(FirstName, ' ', LastName) AS Fullname, 
SUM(od.Quantity * p.Sale_Price) AS total_amount_spent 
FROM customers AS c 
JOIN Orders AS o ON c.CustomerID = o.CustomerID 
JOIN OrderDetails AS od ON o.OrderID = od.OrderID 
JOIN Products AS p ON p.ProductID = od.ProductID 
GROUP BY c.CustomerID, Fullname 
ORDER BY total_amount_spent DESC;

--- Customers are ranked by order frequency to find repeat buyers and frequent shoppers.
SELECT c.CustomerID, 
c.FirstName, 
COUNT(o.OrderID) AS cnt, 
ROW_NUMBER() OVER(ORDER BY COUNT(o.OrderID) DESC) AS rnk
FROM customers AS c 
JOIN orders AS o ON c.CustomerID = o.CustomerID 
GROUP BY c.CustomerID, c.FirstName;

--- Customers placing consecutive orders within 7 days are highlighted to detect highly engaged users.
WITH OrderDates AS (
SELECT c.CustomerID,
o.OrderID,
o.OrderDate,
LAG(o.OrderDate) OVER (PARTITION BY c.CustomerID ORDER BY o.OrderDate) AS PreviousOrderDate
FROM Orders AS o 
JOIN Customers AS c ON o.CustomerID = c.CustomerID)
SELECT CustomerID,
OrderID,
OrderDate,
PreviousOrderDate,
DATEDIFF(OrderDate, PreviousOrderDate) AS DaysBetweenOrders
FROM OrderDates
WHERE PreviousOrderDate IS NOT NULL
AND DATEDIFF(OrderDate, PreviousOrderDate) <= 7
ORDER BY CustomerID, OrderDate;

--- High-Value Customers (Revenue Ranking)
WITH customer_sales AS (
SELECT o.CustomerID, SUM(o.Total_order_amount) AS total_sales
FROM orders o
GROUP BY o.CustomerID)
SELECT CustomerID, total_sales,
RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
LIMIT 10;




--- Section 2: Products & Categories

--- Product sale and market prices are displayed to compare pricing and detect discounts.
SELECT Product, Sale_Price, Market_price
FROM products;

--- Active categories are listed to confirm which categories are currently offered.
SELECT CategoryName, Active
FROM category
WHERE Active = 'Yes';

--- Product counts in each sub-category are calculated to measure product diversity.
SELECT Sub_Category, COUNT(ProductID) AS cnt
FROM products
GROUP BY Sub_Category
ORDER BY cnt DESC;

--- Products sold below market price are identified to track discounts and pricing opportunities.
SELECT ProductID, Product, Sale_Price, Market_Price
FROM products
WHERE Sale_Price < Market_Price;

--- Total quantities sold are calculated to highlight high-demand products.
SELECT Product, SUM(Quantity) AS total_quantity
FROM products AS p 
LEFT JOIN OrderDetails AS od 
ON p.ProductID = od.ProductID
GROUP BY Product 
ORDER BY total_quantity DESC;

--- Sales revenue per product is computed to reveal top revenue contributors.
SELECT p.ProductID, p.Product, 
SUM(od.Quantity * p.Sale_Price) AS total_sales
FROM products AS p 
JOIN orderdetails AS od 
ON p.ProductID = od.ProductID 
GROUP BY p.ProductID, p.Product
ORDER BY total_sales DESC, p.Product ASC;

--- Products are linked with their categories to evaluate performance at both levels.
SELECT c.CategoryName, p.Product 
FROM Category AS c 
JOIN Products AS p 
ON p.Category_ID = c.CategoryID 
ORDER BY c.CategoryName ASC;

--- The average sale price per category is calculated to analyze category pricing strategies.
SELECT c.CategoryName, AVG(p.Sale_Price) AS average_sale_price
FROM Category AS c 
JOIN Products AS p 
ON p.Category_ID = c.CategoryID 
GROUP BY c.CategoryName
ORDER BY c.CategoryName ASC;

--- The top 5 products by sales value are shown to identify best-sellers.
SELECT ProductID, Product, SUM(Sale_Price) AS total_sales_value
FROM products 
GROUP BY ProductID, Product
ORDER BY total_sales_value DESC
LIMIT 5;

--- Products are ranked by total revenue to highlight top-performing items.
SELECT p.ProductID, 
SUM(p.Sale_Price * od.Quantity) AS total_revenue,
DENSE_RANK() OVER(ORDER BY SUM(p.Sale_Price * od.Quantity) DESC) AS rnk 
FROM products AS p 
JOIN orderdetails AS od 
ON p.ProductID = od.ProductID 
GROUP BY p.ProductID;

--- Cumulative revenue per product over time is calculated to observe sales progression.
SELECT p.Product, 
o.OrderDate, 
p.Sale_price * od.Quantity AS total_revenue, 
SUM(p.Sale_price * od.Quantity) OVER(PARTITION BY p.Product ORDER BY o.OrderDate) AS cumulative_sum
FROM products AS p 
JOIN orderdetails AS od 
ON p.ProductID = od.ProductID
JOIN orders AS o 
ON od.OrderID = o.OrderID;

--- Discounts are measured by comparing market and sale price to rank products with the highest markdowns.
SELECT Product, 
Market_Price, 
Sale_Price, 
Market_Price - Sale_Price AS price_difference, 
DENSE_RANK() OVER(ORDER BY (Market_Price - Sale_Price) DESC) AS rank_
FROM products;

--- The best-selling product in each category is identified to reveal category leaders.
WITH top_selling_product AS (
SELECT c.CategoryID, 
c.CategoryName, 
Product, 
SUM(od.Quantity) AS total_quantity, 
DENSE_RANK() OVER(PARTITION BY c.CategoryID ORDER BY SUM(od.Quantity) DESC) AS rank_
FROM category AS c 
JOIN products AS p 
ON c.CategoryID = p.Category_ID 
JOIN orderdetails AS od 
ON p.ProductID = od.ProductID
GROUP BY c.CategoryID, c.CategoryName, Product
)
SELECT CategoryName, Product, total_quantity
FROM top_selling_product
WHERE rank_ = 1 
ORDER BY total_quantity DESC;




--- Section 3: Orders & Revenue Trends

--- Orders with order and ship dates are displayed to assess fulfillment and delivery cycles.
SELECT OrderID, OrderDate, ShipDate
FROM orders;

--- Monthly revenue trends are calculated to uncover seasonal sales fluctuations and high-demand periods
SELECT MONTH(OrderDate) AS month_, 
MONTHNAME(OrderDate) AS month_name, 
SUM(od.Quantity * p.Sale_Price) AS total_revenue 
FROM orders AS o 
JOIN OrderDetails AS od 
ON o.OrderID = od.OrderID 
JOIN Products AS p 
ON od.ProductID = p.ProductID 
GROUP BY month_, month_name 
ORDER BY month_ ASC;




---Section 4: Suppliers & Shipping

--- Suppliers offering more than five products are identified to highlight key partners with broad catalogs.
SELECT s.SupplierID, s.CompanyName, COUNT(DISTINCT p.ProductID) AS cnt
FROM Suppliers AS s 
JOIN OrderDetails AS od ON s.SupplierID = od.SupplierID 
JOIN Products AS p ON od.ProductID = p.ProductID 
GROUP BY s.SupplierID, s.CompanyName
HAVING COUNT(DISTINCT p.Product) > 5
ORDER BY cnt DESC;

--- Supplier revenues are calculated and compared with the average to identify high-performing suppliers.
WITH supplier_revenue AS (
SELECT s.SupplierID, s.CompanyName, 
ROUND(SUM(od.Quantity * p.Sale_Price), 2) AS total_revenue
FROM suppliers AS s 
JOIN orderdetails AS od ON s.SupplierID = od.SupplierID 
JOIN products AS p ON od.ProductID = p.ProductID
GROUP BY s.SupplierID, s.CompanyName
),
overall_revenue AS (
SELECT ROUND(AVG(total_revenue), 0) AS average_revenue
FROM supplier_revenue
)
SELECT SupplierID, CompanyName, total_revenue, average_revenue 
FROM supplier_revenue, overall_revenue 
WHERE total_revenue > average_revenue;

--- Orders shipped by each shipping partner are counted to evaluate workload distribution.
SELECT s.ShipperID, s.CompanyName, COUNT(o.OrderID) AS cnt 
FROM shippers AS s 
JOIN orders AS o ON o.ShipperID = s.ShipperID 
GROUP BY s.ShipperID, s.CompanyName
ORDER BY cnt DESC, s.CompanyName ASC;

--- Average delivery days per shipper are measured to find the fastest and most reliable logistics provider
SELECT s.ShipperID, s.CompanyName,
ROUND(AVG(TIMESTAMPDIFF(DAY, o.OrderDate, o.DeliveryDate)),2) AS average_delivery_days
FROM shippers AS s 
JOIN orders AS o ON s.ShipperID = o.ShipperID 
GROUP BY s.ShipperID, s.CompanyName
ORDER BY average_delivery_days ASC
LIMIT 1;

--- Shipping Efficiency (Delivery Performance)
SELECT s.CompanyName AS shipper_name,
AVG(DATEDIFF(o.DeliveryDate, o.OrderDate)) AS avg_delivery_days,
MIN(DATEDIFF(o.DeliveryDate, o.OrderDate)) AS fastest_delivery,
MAX(DATEDIFF(o.DeliveryDate, o.OrderDate)) AS slowest_delivery
FROM orders o
JOIN shippers s ON o.ShipperID = s.ShipperID
GROUP BY s.CompanyName
ORDER BY avg_delivery_days;