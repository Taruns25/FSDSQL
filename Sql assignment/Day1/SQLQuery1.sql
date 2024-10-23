CREATE DATABASE SalesDB;

USE SalesDB;

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100),
    Email VARCHAR(100)
);

-- Create Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Order_items table
CREATE TABLE Order_items (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
-- Insert sample customers
INSERT INTO Customers (CustomerName, Email)
VALUES 
('Alice Johnson', 'alice.johnson@email.com'),
('Bob Smith', 'bob.smith@email.com'),
('Charlie Davis', 'charlie.davis@email.com');

-- Insert sample products
INSERT INTO Products (ProductName, Price)
VALUES 
('Laptop', 999.99),
('Smartphone', 499.99),
('Headphones', 199.99);

-- Insert sample orders
INSERT INTO Orders (CustomerID, OrderDate)
VALUES 
(1, '2024-10-01'),
(2, '2024-10-02'),
(3, '2024-10-03');

-- Insert sample order items
INSERT INTO Order_items (OrderID, ProductID, Quantity)
VALUES 
(1, 1, 1),  -- Alice buys a Laptop
(2, 2, 2),  -- Bob buys two Smartphones
(3, 3, 1),  -- Charlie buys Headphones
(3, 1, 1);  -- Charlie also buys a Laptop

-- View Customers
SELECT * FROM Customers;

-- View Products
SELECT * FROM Products;

-- View Orders
SELECT * FROM Orders;

-- View Order Items
SELECT * FROM Order_items;


CREATE PROCEDURE GetCustomersByProductID
    @ProductID INT
AS
BEGIN
    SELECT 
        C.CustomerID,
        C.CustomerName,
        O.OrderDate AS PurchaseDate
    FROM 
        Customers C
        INNER JOIN Orders O ON C.CustomerID = O.CustomerID
        INNER JOIN Order_items OI ON O.OrderID = OI.OrderID
        INNER JOIN Products P ON OI.ProductID = P.ProductID
    WHERE 
        P.ProductID = @ProductID;
END;


EXEC GetCustomersByProductID @ProductID = 1;


CREATE FUNCTION CalculateTotalPrice
(
    @ProductID INT,
    @Quantity INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @UnitPrice DECIMAL(10, 2);
    DECLARE @TotalPrice DECIMAL(10, 2);

    -- Get the price of the product from the Products table
    SELECT @UnitPrice = Price
    FROM Products
    WHERE ProductID = @ProductID;

    -- Calculate the total price
    SET @TotalPrice = @UnitPrice * @Quantity;

    -- Return the total price
    RETURN @TotalPrice;
END;


SELECT dbo.CalculateTotalPrice(1, 3) AS TotalPrice;

CREATE FUNCTION GetCustomerOrders
(
    @CustomerID INT
)
RETURNS @OrderDetails TABLE
(
    OrderID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert order details into the table variable
    INSERT INTO @OrderDetails (OrderID, OrderDate, TotalAmount)
    SELECT 
        O.OrderID,
        O.OrderDate,
        SUM(OI.Quantity * P.Price) AS TotalAmount
    FROM 
        Orders O
        INNER JOIN Order_items OI ON O.OrderID = OI.OrderID
        INNER JOIN Products P ON OI.ProductID = P.ProductID
    WHERE 
        O.CustomerID = @CustomerID
    GROUP BY 
        O.OrderID, O.OrderDate;

    RETURN;
END;

SELECT * FROM dbo.GetCustomerOrders(1);

CREATE FUNCTION GetTotalSalesPerProduct()
RETURNS @ProductSales TABLE
(
    ProductID INT,
    ProductName VARCHAR(100),
    TotalSales DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert total sales per product into the table variable
    INSERT INTO @ProductSales (ProductID, ProductName, TotalSales)
    SELECT 
        P.ProductID,
        P.ProductName,
        SUM(OI.Quantity * P.Price) AS TotalSales
    FROM 
        Products P
        INNER JOIN Order_items OI ON P.ProductID = OI.ProductID
    GROUP BY 
        P.ProductID, P.ProductName;

    RETURN;
END;

-- Get total sales for each product
SELECT * FROM dbo.GetTotalSalesPerProduct();

CREATE FUNCTION GetTotalSpentByCustomer()
RETURNS @CustomerSpending TABLE
(
    CustomerID INT,
    CustomerName VARCHAR(100),
    TotalSpent DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert customer spending details into the table variable
    INSERT INTO @CustomerSpending (CustomerID, CustomerName, TotalSpent)
    SELECT 
        C.CustomerID,
        C.CustomerName,
        SUM(OI.Quantity * P.Price) AS TotalSpent
    FROM 
        Customers C
        INNER JOIN Orders O ON C.CustomerID = O.CustomerID
        INNER JOIN Order_items OI ON O.OrderID = OI.OrderID
        INNER JOIN Products P ON OI.ProductID = P.ProductID
    GROUP BY 
        C.CustomerID, C.CustomerName;

    RETURN;
END;

-- Get the total amount spent by all customers
SELECT * FROM dbo.GetTotalSpentByCustomer();

