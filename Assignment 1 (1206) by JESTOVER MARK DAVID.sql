CREATE DATABASE ORG;
USE ORG;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(255),
    Email VARCHAR(255),
    JoinDate DATE
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(255),
    Category VARCHAR(255),
    Price DECIMAL(10, 2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PricePerUnit DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Customers (CustomerID, Name, Email, JoinDate) VALUES
(1, 'John Doe', 'johndoe@example.com', '2020-01-10'),
(2, 'Jane Smith', 'janesmith@example.com', '2020-01-15'),
(3, 'Michael Brown', 'michaelbrown@example.com', '2020-02-05'),
(4, 'Emily Davis', 'emilydavis@example.com', '2020-02-10'),
(5, 'William Wilson', 'williamwilson@example.com', '2020-02-15'),
(6, 'Olivia Martinez', 'oliviamartinez@example.com', '2020-02-20'),
(7, 'James Taylor', 'jamestaylor@example.com', '2020-02-25'),
(8, 'Sophia Thomas', 'sophiathomas@example.com', '2020-02-28'),
(9, 'Daniel Hernandez', 'danielhernandez@example.com', '2020-03-01'),
(10, 'Alice Johnson', 'alicejohnson@example.com', '2020-03-05');

INSERT INTO Products (ProductID, Name, Category, Price) VALUES
(1, 'Laptop', 'Electronics', 999.99),
(2, 'Smartphone', 'Electronics', 499.99),
(3, 'Tablet', 'Electronics', 299.99),
(4, 'Headphones', 'Electronics', 99.99),
(5, 'Smart Watch', 'Electronics', 199.99),
(6, 'Blender', 'Kitchen Appliances', 79.99),
(7, 'Coffee Maker', 'Kitchen Appliances', 149.99),
(8, 'Desk Chair', 'Furniture', 199.99),
(9, 'Throw Pillow', 'Home Decor', 19.99),
(10, 'Desk Lamp', 'Home Decor', 29.99),
(11, 'Air conditioner', 'Electronics', 137.96);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES
(1, 1, '2024-02-15', 1499.98),
(2, 2, '2024-02-17', 499.99),
(3, 1, '2024-02-20', 299.99),
(4, 3, '2024-02-22', 99.99),
(5, 2, '2024-05-08', 399.99),
(6, 4, '2024-03-01', 149.99),
(7, 5, '2024-03-05', 199.99),
(8, 6, '2024-03-10', 79.99),
(9, 7, '2024-03-15', 29.99),
(10, 1, '2024-04-21', 78.99);

INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, PricePerUnit) VALUES
(1, 1, 1, 1, 999.99),
(2, 1, 2, 1, 499.99),
(3, 2, 3, 1, 299.99),
(4, 2, 4, 1, 99.99),
(5, 3, 5, 1, 199.99),
(6, 4, 6, 1, 79.99),
(7, 4, 7, 1, 149.99),
(8, 5, 8, 1, 199.99),
(9, 5, 9, 2, 19.99),
(10, 5, 10, 2, 29.99);

SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

-- 1. Basic Queries
-- 1.1. List all customers.
SELECT * FROM Customers;

-- 1.2. Show all products in the 'Electronics' category.
SELECT * FROM Products WHERE Category = 'Electronics';

-- 1.3. Find the total number of orders placed.
SELECT COUNT(*) AS TotalOrders FROM Orders;

-- 1.4. Display the details of the most recent order.
SELECT * FROM Orders ORDER BY OrderDate DESC LIMIT 1;

-- 2. Joins and Relationships
-- 2.1. List all products along with the names of the customers who ordered them.
SELECT p.*, c.Name AS CustomerName
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID;

-- 2.2. Show orders that include more than one product.
SELECT o.*
FROM Orders o
JOIN (
    SELECT OrderID, COUNT(*) AS ProductCount
    FROM OrderDetails
    GROUP BY OrderID
    HAVING COUNT(*) > 1
) AS multi_product_orders ON o.OrderID = multi_product_orders.OrderID;

-- 2.3. Find the total sales amount for each customer.
SELECT c.CustomerID, c.Name AS CustomerName, COALESCE(SUM(o.TotalAmount), 0) AS TotalSales
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name;

-- 3. Aggregation and Grouping
-- 3.1. Calculate the total revenue generated by each product category.
SELECT Category, COALESCE(SUM(Price * Quantity), 0) AS TotalRevenue
FROM Products
LEFT JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Category;

-- 3.2. Determine the average order value.
SELECT AVG(TotalAmount) AS AverageOrderValue
FROM Orders;

-- 3.3. Find the month with the highest number of orders.
SELECT MONTH(OrderDate) AS Month, COUNT(*) AS TotalOrders
FROM Orders
GROUP BY Month
ORDER BY TotalOrders DESC
LIMIT 1;

-- 4. Subqueries and Nested Queries
-- 4.1. Identify customers who have not placed any orders.
SELECT *
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);

-- 4.2. Find products that have never been ordered.
SELECT *
FROM Products
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM OrderDetails);

-- 4.3. Show the top 3 best-selling products.
SELECT p.*, COALESCE(SUM(od.Quantity), 0) AS TotalQuantitySold
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalQuantitySold DESC
LIMIT 3;

-- 5. Date and Time Functions
-- 5.1. List orders placed in the last month.
SELECT * FROM Orders WHERE OrderDate >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);

-- 5.2. Determine the oldest customer in terms of membership duration.
SELECT CustomerID, Name, JoinDate, DATEDIFF(CURRENT_DATE(), JoinDate) AS MembershipDuration
FROM Customers
ORDER BY MembershipDuration DESC
LIMIT 1;


-- 6. Advanced Queries
-- 6.1. Rank customers based on their total spending.
SELECT c.CustomerID, c.Name, COALESCE(SUM(o.TotalAmount), 0) AS TotalSpending,
       RANK() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS Ranking
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name;

-- 6.2. Identify the most popular product category.
SELECT Category, COALESCE(COUNT(*), 0) AS TotalOrders
FROM Products
LEFT JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Category
ORDER BY TotalOrders DESC
LIMIT 1;

-- 6.3. Calculate the month-over-month growth rate in sales.
SELECT MONTH(OrderDate) AS Month, COALESCE(SUM(TotalAmount), 0) AS TotalSales,
       ROUND((SUM(TotalAmount) - LAG(SUM(TotalAmount), 1) OVER (ORDER BY MONTH(OrderDate))) / LAG(SUM(TotalAmount), 1) OVER (ORDER BY MONTH(OrderDate)) * 100, 2) AS GrowthRate
FROM Orders
GROUP BY Month;

-- 7. Data Manipulation and Updates
-- 7.1. Add a new customer to the Customers table.
INSERT INTO Customers (CustomerID, Name, Email, JoinDate)
VALUES (11, 'Sarah Brown', 'sarahbrown@example.com', '2020-03-25');
SELECT * FROM Customers;


-- 7.2. Update the price of a specific product.
UPDATE Products SET Price = 109.99 WHERE ProductID = 10;
SELECT * FROM Products;
