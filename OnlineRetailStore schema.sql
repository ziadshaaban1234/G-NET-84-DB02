-- ============================================================
-- Online Retail Store Management System
-- Relational Schema Implementation
-- Dialect: T-SQL (SQL Server)
-- ============================================================


-- Categorized: Category (1) -- Category (M)
CREATE TABLE Category
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    MainCategory INT NULL,

    CONSTRAINT FK_Category_MainCategory
        FOREIGN KEY (MainCategory)
        REFERENCES Category(CategoryID)
);


-- Supplier
CREATE TABLE Supplier
(
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    ContactNumber NVARCHAR(20) NULL,
    Email NVARCHAR(150) NULL,
    Address NVARCHAR(250) NULL,
    Country NVARCHAR(100) NULL
);


-- Product
CREATE TABLE Product
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Description NVARCHAR(1000) NULL,
    AddedDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    StockQuntity INT NOT NULL DEFAULT 0,
    CategoryID INT NOT NULL,

    CONSTRAINT FK_Product_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
);


-- Supply: Supplier (M) -- Product (M)
CREATE TABLE ProductSupplier
(
    SupplierID INT NOT NULL,
    ProductID INT NOT NULL,

    CONSTRAINT PK_ProductSupplier
        PRIMARY KEY (SupplierID, ProductID),

    CONSTRAINT FK_ProductSupplier_Supplier
        FOREIGN KEY (SupplierID)
        REFERENCES Supplier(SupplierID),

    CONSTRAINT FK_ProductSupplier_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
);


-- Customer
CREATE TABLE Customer
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(20) NULL,
    FullName NVARCHAR(150) NOT NULL,
    RegisterationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ShipingAddress NVARCHAR(250) NULL
);


-- Include: Product (1) -- Stocktransaction (M)
CREATE TABLE Stocktransaction
(
    TranID INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(3) NOT NULL,
    TranDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    QuantityChange INT NOT NULL,
    Reference INT NULL,
    ProductID INT NOT NULL,

    CONSTRAINT FK_Stocktransaction_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID),

    CONSTRAINT CK_Stocktransaction_Type
        CHECK (Type IN ('in', 'out'))
);


-- Place: Customer (1) -- Order (M)
CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    Status NVARCHAR(50) NOT NULL,
    TotalAmmount DECIMAL(10,2) NOT NULL,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CustomerID INT NOT NULL,

    CONSTRAINT FK_Orders_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
);


-- Represent: Product (1) -- OrderItem (M)
-- Contains: Order (1) -- OrderItem (M)
CREATE TABLE OrderItem
(
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    PriceUnit DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    ProductID INT NOT NULL,
    OrderID INT NOT NULL,

    CONSTRAINT FK_OrderItem_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID),

    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);


-- Reviews: Product (1) -- Review (M)
-- Reviewed By: Customer (1) -- Review (M)
CREATE TABLE Review
(
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    Rating INT NOT NULL,
    Date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Comment NVARCHAR(1000) NULL,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,

    CONSTRAINT FK_Review_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID),

    CONSTRAINT FK_Review_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),

    CONSTRAINT CK_Review_Rating
        CHECK (Rating BETWEEN 1 AND 5)
);


-- Payment
CREATE TABLE Payment
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentDate DATETIME2 NOT NULL,
    Ammount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    Method NVARCHAR(50) NOT NULL
);


-- Linked: Order (M) -- Payment (M)
CREATE TABLE OrderPayment
(
    OrderID INT NOT NULL,
    PaymentID INT NOT NULL,

    CONSTRAINT PK_OrderPayment
        PRIMARY KEY (OrderID, PaymentID),

    CONSTRAINT FK_OrderPayment_Order
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderPayment_Payment
        FOREIGN KEY (PaymentID)
        REFERENCES Payment(PaymentID)
);


-- Have: Order (1) -- Shipment (M)
CREATE TABLE Shipment
(
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentDate DATETIME2 NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    DeliveryDate DATETIME2 NULL,
    CarrierName NVARCHAR(100) NOT NULL,
    TrackingNumber NVARCHAR(100) NULL,
    OrderID INT NOT NULL,

    CONSTRAINT FK_Shipment_Order
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);