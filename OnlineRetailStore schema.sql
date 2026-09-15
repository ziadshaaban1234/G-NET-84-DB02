-- ============================================================
-- Online Retail Store Management System - Relational Mapping
-- Mapped from the provided ER diagram (Chen notation)
-- Dialect: T-SQL (SQL Server)
-- ============================================================

-- Categorized: Category (1) -- Category (M), self-referencing for subcategories
CREATE TABLE Category (
    CategoryId          INT IDENTITY(1,1) PRIMARY KEY,
    Name                NVARCHAR(100) NOT NULL,
    Description         NVARCHAR(500) NULL,
    ParentCategoryId    INT NULL,
    CONSTRAINT FK_Category_ParentCategory FOREIGN KEY (ParentCategoryId)
        REFERENCES Category (CategoryId)
);

CREATE TABLE Supplier (
    SupplierId      INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    ContactNumber   NVARCHAR(20) NULL,
    Email           NVARCHAR(150) NULL,
    Address         NVARCHAR(250) NULL,
    Country         NVARCHAR(100) NULL
);

-- Belongs: Product (M) -- Category (1)
CREATE TABLE Product (
    ProductId       INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    Description     NVARCHAR(1000) NULL,
    UnitPrice       DECIMAL(10, 2) NOT NULL,
    StockQuantity   INT NOT NULL DEFAULT 0,
    AddedDate       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CategoryId      INT NOT NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId)
        REFERENCES Category (CategoryId)
);

-- Supply: Supplier (M) -- Product (M)
CREATE TABLE ProductSupplier (
    ProductId   INT NOT NULL,
    SupplierId  INT NOT NULL,
    CONSTRAINT PK_ProductSupplier PRIMARY KEY (ProductId, SupplierId),
    CONSTRAINT FK_ProductSupplier_Product FOREIGN KEY (ProductId)
        REFERENCES Product (ProductId),
    CONSTRAINT FK_ProductSupplier_Supplier FOREIGN KEY (SupplierId)
        REFERENCES Supplier (SupplierId)
);

CREATE TABLE Customer (
    CustomerId          INT IDENTITY(1,1) PRIMARY KEY,
    FullName            NVARCHAR(150) NOT NULL,
    Email               NVARCHAR(150) NOT NULL UNIQUE,
    PhoneNumber         NVARCHAR(20) NULL,
    ShippingAddress     NVARCHAR(250) NULL,
    RegistrationDate    DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

-- Include: Product (1) -- Stocktransaction (M)
CREATE TABLE Stocktransaction (
    TranId          INT IDENTITY(1,1) PRIMARY KEY,
    TranDate        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    QuantityChange  INT NOT NULL,
    Type            NVARCHAR(3) NOT NULL,
    Reference       INT NULL,
    ProductId       INT NOT NULL,
    CONSTRAINT FK_Stocktransaction_Product FOREIGN KEY (ProductId)
        REFERENCES Product (ProductId),
    CONSTRAINT CK_Stocktransaction_Type CHECK (Type IN ('in', 'out'))
);

-- Place: Customer (1) -- Order (M)
CREATE TABLE Orders (
    OrderId     INT IDENTITY(1,1) PRIMARY KEY,
    Status      NVARCHAR(50) NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    OrderDate   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CustomerId  INT NOT NULL,
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerId)
        REFERENCES Customer (CustomerId)
);

-- Represent: Product (1) -- OrderItem (M); Contains: Order (1) -- OrderItem (M)
CREATE TABLE OrderItem (
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    Quantity    INT NOT NULL,
    UnitPrice   DECIMAL(10, 2) NOT NULL,
    ProductId   INT NOT NULL,
    OrderId     INT NOT NULL,
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY (ProductId)
        REFERENCES Product (ProductId),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (OrderId)
        REFERENCES Orders (OrderId)
);

-- Reviews: Product (1) -- Review (M); "Reviewed By": Customer (1) -- Review (M)
CREATE TABLE Review (
    ReviewId    INT IDENTITY(1,1) PRIMARY KEY,
    Rating      INT NOT NULL,
    ReviewDate  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Comment     NVARCHAR(1000) NULL,
    ProductId   INT NOT NULL,
    CustomerId  INT NOT NULL,
    CONSTRAINT FK_Review_Product FOREIGN KEY (ProductId)
        REFERENCES Product (ProductId),
    CONSTRAINT FK_Review_Customer FOREIGN KEY (CustomerId)
        REFERENCES Customer (CustomerId),
    CONSTRAINT CK_Review_Rating CHECK (Rating BETWEEN 1 AND 5)
);

CREATE TABLE Payment (
    PaymentId   INT IDENTITY(1,1) PRIMARY KEY,
    Method      NVARCHAR(50) NOT NULL,
    Status      NVARCHAR(50) NOT NULL,
    Amount      DECIMAL(10, 2) NOT NULL,
    PaymentDate DATETIME2 NOT NULL
);

-- Linked: Order (M) -- Payment (M)
CREATE TABLE OrderPayment (
    OrderId     INT NOT NULL,
    PaymentId   INT NOT NULL,
    CONSTRAINT PK_OrderPayment PRIMARY KEY (OrderId, PaymentId),
    CONSTRAINT FK_OrderPayment_Order FOREIGN KEY (OrderId)
        REFERENCES Orders (OrderId),
    CONSTRAINT FK_OrderPayment_Payment FOREIGN KEY (PaymentId)
        REFERENCES Payment (PaymentId)
);

-- Have: Order (1) -- Shipment (M)
CREATE TABLE Shipment (
    ShipmentId      INT IDENTITY(1,1) PRIMARY KEY,
    TrackingNumber  NVARCHAR(100) NULL,
    CarrierName     NVARCHAR(100) NOT NULL,
    DeliveryDate    DATETIME2 NULL,
    Status          NVARCHAR(50) NOT NULL,
    ShipmentDate    DATETIME2 NOT NULL,
    OrderId         INT NOT NULL,
    CONSTRAINT FK_Shipment_Order FOREIGN KEY (OrderId)
        REFERENCES Orders (OrderId)
);
