-- Create the database
CREATE DATABASE MyTest;
USE MyTest;

CREATE TABLE Venditors (
    VenditorID INT PRIMARY KEY IDENTITY,
    VenditorName NVARCHAR(100),
    VenditorCountry NVARCHAR(100)
);


INSERT INTO Venditors ( VenditorName, VenditorCountry)
VALUES
    ( 'GE', N'Німеччина'),
    ( 'PD', N'Італія'),
    ( 'ANV', N'Франція'),
    ( 'GE', N'США'),
    ('ANV', N'США');

   SELECT * from Venditors

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    ProductName NVARCHAR(100),
    VenditorRef INT,
    FOREIGN KEY (VenditorRef) REFERENCES Venditors(VenditorID)
);


INSERT INTO Products ( ProductName, VenditorRef)
VALUES
    ( 'Carrot', 5),
    ( 'Cucumber', 3),
    ( 'Beet', 5),
    ( 'Potato', 1),
    ( 'Onion', 4),
    ( 'Tomato', 2);





CREATE TABLE ProductPrice (
    ProductPriceID INT PRIMARY KEY IDENTITY,
    ProductRef INT,
    ProductPriceRate DECIMAL(10, 2),
    ProductPriceStartDate DATE,
    ProductPriceEndDate DATE,
    FOREIGN KEY (ProductRef) REFERENCES Products(ProductID)
);


INSERT INTO ProductPrice (ProductRef, ProductPriceRate, ProductPriceStartDate, ProductPriceEndDate)
VALUES
    ( 1, 10.00, '2023-01-01', '2023-03-24'),
    ( 2, 20.00, '2024-01-01', NULL),
    (3, 31.00, '2023-01-01', '2023-02-28'),
    ( 4, 15.00, '2023-01-01', NULL),
    ( 5, 45.00, '2023-01-01', '2023-03-24'),
    ( 6, 24.00, '2023-01-01', '2023-03-28'),
    ( 3, 25.00, '2023-03-01', '2023-03-31'),
    ( 5, 52.00, '2023-03-25', '2023-03-28'),
    ( 5, 55.00, '2023-03-29', NULL),
    ( 1, 12.00, '2023-03-25', '2023-03-28'),
    ( 1, 19.00, '2023-03-29', NULL),
    ( 3, 29.00, '2023-04-01', NULL),
    ( 6, 29.00, '2023-03-29', NULL);

-- Вибрати товари, назва яких починається на літеру "С"
SELECT *
FROM Products
WHERE ProductName LIKE 'C%';

-- Вибрати товари, продавець яких з США
SELECT p.*
FROM Products p
JOIN Venditors v ON p.VenditorRef = v.VenditorID
WHERE v.VenditorCountry = N'США';

-- Вибрати товари, продавець яких GE
SELECT p.*
FROM Products p
JOIN  Venditors v ON p.VenditorRef = v.VenditorID
WHERE v.VenditorName = 'GE';

-- Вибрати товари, продавці яких GE та PD
SELECT p.*
FROM Products p
JOIN Venditors v ON p.VenditorRef = v.VenditorID
WHERE v.VenditorName IN ('GE', 'PD');

-- Додати новий товар в таблицю Products: продавець SR Сирія

INSERT INTO Venditors (VenditorName, VenditorCountry)
VALUES
    ('SR', N'Сирія');
INSERT INTO Products (ProductName, VenditorRef)
VALUES ('New Product', (SELECT VenditorID FROM Venditors WHERE VenditorName = 'SR'));


-- Додати ціну для новоствореного товару
INSERT INTO ProductPrice (ProductRef, ProductPriceRate, ProductPriceStartDate, ProductPriceEndDate)
VALUES ((SELECT MAX(ProductID) FROM Products), 20.00, GETDATE(), NULL);


-- Вибрати усі актуальні ціни на товари/залишити у вибірці лише колонки: ProductID, ProductName, ProductPriceRate
SELECT p.ProductID, p.ProductName, pp.ProductPriceRate
FROM Products p
JOIN ProductPrice pp ON p.ProductID = pp.ProductRef
WHERE pp.ProductPriceStartDate <= GETDATE()
  AND (pp.ProductPriceEndDate IS NULL OR pp.ProductPriceEndDate >= GETDATE());

-- Знайти актуальну ціну для товарів Tomato та Carrot 
SELECT p.ProductName, pp.ProductPriceRate
FROM Products p
JOIN ProductPrice pp ON p.ProductID = pp.ProductRef
WHERE p.ProductName IN ('Tomato', 'Carrot')
  AND pp.ProductPriceStartDate <= GETDATE()
  AND (pp.ProductPriceEndDate IS NULL OR pp.ProductPriceEndDate >= GETDATE());

-- Змінити країну продавця ANV на Данія
UPDATE Venditors
SET VenditorCountry = N'Данія'
WHERE VenditorName = 'ANV';


-- Змінити назву товару Onion на Garliс
UPDATE Products
SET ProductName = 'Garlic'
WHERE ProductName = 'Onion';

-- Вибрати унікальних продавців товарів
SELECT DISTINCT VenditorName
FROM Venditors;

-- Змінити ціну на товар Beet (ціна довільна), яка діятиме з 01.05.2023
UPDATE ProductPrice
SET ProductPriceRate = 4500, ProductPriceStartDate = '2023-05-01'
WHERE ProductRef = (SELECT ProductID FROM Products WHERE ProductName = 'Beet');

-- Вибрати товари, ціна яких від 10 до 20 у.о.
SELECT p.ProductName, pp.ProductPriceRate
FROM Products p
JOIN ProductPrice pp ON p.ProductID = pp.ProductRef
WHERE pp.ProductPriceRate BETWEEN 10 AND 20

-- Вибрати товари, ціна яких не дорівнює 29 у.о.

SELECT p.ProductName, pp.ProductPriceRate
FROM Products p
JOIN ProductPrice pp ON p.ProductID = pp.ProductRef
WHERE pp.ProductPriceRate <> 29.00;

-- Вибрати товари, назва продаців яких починається літери "А" та "Р"
SELECT p.ProductName, v.VenditorName
FROM Products p
JOIN Venditors v ON p.VenditorRef = v.VenditorID
WHERE v.VenditorName LIKE 'A%' OR v.VenditorName LIKE 'P%';

-- Створити таблицю Orders замовлень з наступними колонками:  OrderID (ID проставлятись автоматично), ProductRef, VenditorRef, Quantity, OrderDate

CREATE TABLE Orders (
    OrderID INT IDENTITY PRIMARY KEY,
    ProductRef INT,
    VenditorRef INT,
    Quantity INT,
    OrderDate DATE,
    FOREIGN KEY (ProductRef) REFERENCES Products(ProductID),
    FOREIGN KEY (VenditorRef) REFERENCES Venditors(VenditorID)
);


-- Створити по 3 замовлення на товари: Cucumber, Potato, Tomato

INSERT INTO Orders (ProductRef, VenditorRef, Quantity, OrderDate)
SELECT p.ProductID, p.VenditorRef, 2, GETDATE()
FROM Products p
WHERE p.ProductName = 'Cucumber'
UNION ALL
SELECT p.ProductID, p.VenditorRef, 3, GETDATE()
FROM Products p
WHERE p.ProductName = 'Potato'
UNION ALL
SELECT p.ProductID, p.VenditorRef, 1, GETDATE()
FROM Products p
WHERE p.ProductName = 'Tomato';
UNION ALL
SELECT p.ProductID, p.VenditorRef, 5, GETDATE()
FROM Products p
WHERE p.ProductName = 'Cucumber'
UNION ALL
SELECT p.ProductID, p.VenditorRef, 7, GETDATE()
FROM Products p
WHERE p.ProductName = 'Potato'
UNION ALL
SELECT p.ProductID, p.VenditorRef, 9, GETDATE()
FROM Products p
WHERE p.ProductName = 'Tomato';

UNION ALL
SELECT p.ProductID, p.VenditorRef, 5, GETDATE()
FROM Products p
WHERE p.ProductName = 'Cucumber'
UNION ALL
SELECT p.ProductID, p.VenditorRef, 3, GETDATE()
FROM Products p
WHERE p.ProductName = 'Potato'
UNION ALL
SELECT p.ProductID, p.VenditorRef, 8, GETDATE()
FROM Products p
WHERE p.ProductName = 'Tomato';


-- Порахувати загальну вартість замовлення по товару Tomato
SELECT
  SUM(pp.ProductPriceRate * o.Quantity) AS TotalCost
FROM Orders o
JOIN Products p ON o.ProductRef = p.ProductID
JOIN ProductPrice pp ON o.ProductRef = pp.ProductRef
WHERE p.ProductName = 'Tomato';