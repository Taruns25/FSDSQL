--Create a Trigger to Update the Stock (Quantity) Table Whenever a New Order is Placed
CREATE TABLE Stock
(
    ProductID INT PRIMARY KEY,
    Quantity INT -- Total available stock
);

CREATE TRIGGER UpdateStockOnOrder
ON Order_items
AFTER INSERT
AS
BEGIN
    UPDATE S
    SET S.Quantity = S.Quantity - OI.Quantity
    FROM Stock S
    INNER JOIN inserted OI ON S.ProductID = OI.ProductID;

    PRINT 'Stock updated successfully after new order.';
END;

--Create a Trigger to Prevent Deletion of a Customer if They Have Existing Orders
CREATE TRIGGER PreventCustomerDeletion
ON Customers
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Orders O WHERE O.CustomerID IN (SELECT CustomerID FROM deleted))
    BEGIN
        PRINT 'Cannot delete customer with existing orders.';
    END
    ELSE
    BEGIN
        DELETE FROM Customers WHERE CustomerID IN (SELECT CustomerID FROM deleted);
        PRINT 'Customer deleted successfully.';
    END;
END;


--Create Employee and Employee_Audit Tables, and a Trigger to Log Changes
CREATE TABLE Employee
(
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Salary DECIMAL(10, 2)
);

CREATE TABLE Employee_Audit
(
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    ChangeType VARCHAR(50), -- Insert, Update, Delete
    ChangedBy VARCHAR(100),
    ChangeDate DATETIME,
    OldSalary DECIMAL(10, 2) NULL, -- Nullable in case of Insert
    NewSalary DECIMAL(10, 2) NULL  -- Nullable in case of Delete
);

INSERT INTO Employee (EmployeeID, Name, Position, Salary)
VALUES 
(1, 'John Doe', 'Manager', 80000),
(2, 'Jane Smith', 'Developer', 60000);

CREATE TRIGGER LogEmployeeChanges
ON Employee
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    -- Handle INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Employee_Audit (EmployeeID, ChangeType, ChangedBy, ChangeDate, NewSalary)
        SELECT EmployeeID, 'Insert', SYSTEM_USER, GETDATE(), Salary
        FROM inserted;

        PRINT 'Employee insertion logged in Employee_Audit table.';
    END

    -- Handle UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Employee_Audit (EmployeeID, ChangeType, ChangedBy, ChangeDate, OldSalary, NewSalary)
        SELECT d.EmployeeID, 'Update', SYSTEM_USER, GETDATE(), d.Salary, i.Salary
        FROM deleted d
        INNER JOIN inserted i ON d.EmployeeID = i.EmployeeID;

        PRINT 'Employee update logged in Employee_Audit table.';
    END

    -- Handle DELETE
    IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Employee_Audit (EmployeeID, ChangeType, ChangedBy, ChangeDate, OldSalary)
        SELECT EmployeeID, 'Delete', SYSTEM_USER, GETDATE(), Salary
        FROM deleted;

        PRINT 'Employee deletion logged in Employee_Audit table.';
    END
END;

--10) create Room Table with below columns RoomID,RoomType,Availability create Bookins Table with below columns BookingID,RoomID,CustomerName,CheckInDate,CheckInDate
CREATE TABLE Room
(
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomType VARCHAR(50),
    Availability BIT -- 1 = Available, 0 = Unavailable
);

CREATE TABLE Bookings
(
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    RoomID INT,
    CustomerName VARCHAR(100),
    CheckInDate DATE,
    CheckOutDate DATE,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID) -- Foreign key relationship
);

INSERT INTO Room (RoomType, Availability)
VALUES 
('Single', 1),    
('Double', 1),   
('Suite', 1);     


INSERT INTO Bookings (RoomID, CustomerName, CheckInDate, CheckOutDate)
VALUES 
(1, 'John Doe', '2024-10-25', '2024-10-28');

BEGIN TRANSACTION;

DECLARE @RoomID INT = 2;  -- Example room ID to book
DECLARE @CustomerName VARCHAR(100) = 'Jane Smith';
DECLARE @CheckInDate DATE = '2024-11-01';
DECLARE @CheckOutDate DATE = '2024-11-05';

-- Check if the room is available
IF EXISTS (SELECT * FROM Room WHERE RoomID = @RoomID AND Availability = 1)
BEGIN
    -- Insert booking record
    INSERT INTO Bookings (RoomID, CustomerName, CheckInDate, CheckOutDate)
    VALUES (@RoomID, @CustomerName, @CheckInDate, @CheckOutDate);

    -- Mark room as unavailable
    UPDATE Room
    SET Availability = 0
    WHERE RoomID = @RoomID;

    COMMIT TRANSACTION;
    PRINT 'Room booked successfully and marked as unavailable.';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Room is unavailable for booking.';
END;
