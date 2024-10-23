-- Create Department table
CREATE TABLE Departments (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100)
);

-- Create Employee table
CREATE TABLE Employees (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100),
    Gender CHAR(1), -- 'M' for Male, 'F' for Female
    DOB DATE,
    DeptId INT,
    FOREIGN KEY (DeptId) REFERENCES Departments(ID)
);
-- Insert sample data into Department table
INSERT INTO Departments(Name)
VALUES 
('HR'),
('Finance'),
('Engineering'),
('Marketing');

-- Insert sample data into Employee table
INSERT INTO Employees (Name, Gender, DOB, DeptId)
VALUES 
('John Doe', 'M', '1990-01-15', 3),    -- Engineering
('Jane Smith', 'F', '1985-06-25', 1),  -- HR
('Michael Brown', 'M', '1992-11-10', 2), -- Finance
('Emily White', 'F', '1993-09-08', 3), -- Engineering
('Robert Green', 'M', '1988-05-20', 4); -- Marketing


CREATE PROCEDURE UpdateEmployeeByID
    @EmployeeID INT,
    @Name VARCHAR(100),
    @Gender CHAR(1),
    @DOB DATE,
    @DeptId INT
AS
BEGIN
    UPDATE Employees
    SET 
        Name = @Name,
        Gender = @Gender,
        DOB = @DOB,
        DeptId = @DeptId
    WHERE 
        ID = @EmployeeID;
END;

EXEC UpdateEmployeeByID
    @EmployeeID = 1,
    @Name = 'John Doe II',
    @Gender = 'M',
    @DOB = '1990-01-15',
    @DeptId = 3;


CREATE PROCEDURE GetEmployeesByGenderAndDept
    @Gender CHAR(1),
    @DeptId INT
AS
BEGIN
    SELECT 
        E.ID, 
        E.Name, 
        E.Gender, 
        E.DOB, 
        D.Name AS DepartmentName
    FROM 
        Employees E
        INNER JOIN Departments D ON E.DeptId = D.ID
    WHERE 
        E.Gender = @Gender
        AND E.DeptId = @DeptId;
END;

EXEC GetEmployeesByGenderAndDept
    @Gender = 'F',
    @DeptId = 3;


CREATE PROCEDURE GetEmployeeCountByGender
    @Gender CHAR(1)
AS
BEGIN
    SELECT 
        COUNT(*) AS EmployeeCount
    FROM 
        Employees
    WHERE 
        Gender = @Gender;
END;

EXEC GetEmployeeCountByGender
    @Gender = 'M';
