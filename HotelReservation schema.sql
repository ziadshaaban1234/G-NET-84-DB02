-- ============================================================
-- Hotel Reservation Management System
-- Relational Schema Implementation
-- Dialect: T-SQL (SQL Server)
-- ============================================================

CREATE TABLE Hotel
(
    HotelID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Address NVARCHAR(250) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    StarRating INT NOT NULL,
    ContactNumber NVARCHAR(20) NULL,
    ManageID INT NULL UNIQUE,

    CONSTRAINT CK_Hotel_StarRating
        CHECK (StarRating BETWEEN 1 AND 5)
);


CREATE TABLE Staff
(
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    HotelID INT NOT NULL,

    CONSTRAINT FK_Staff_Hotel
        FOREIGN KEY (HotelID)
        REFERENCES Hotel(HotelID)
);


ALTER TABLE Hotel
ADD CONSTRAINT FK_Hotel_Manage
    FOREIGN KEY (ManageID)
    REFERENCES Staff(StaffID);


CREATE TABLE Room
(
    RoomNumber NVARCHAR(10) PRIMARY KEY,
    RoomType NVARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    DailyRate DECIMAL(10,2) NOT NULL,
    Availability NVARCHAR(50) NOT NULL,
    HotelID INT NOT NULL,

    CONSTRAINT FK_Room_Hotel
        FOREIGN KEY (HotelID)
        REFERENCES Hotel(HotelID)
);


CREATE TABLE RoomAmenity
(
    RoomNumber NVARCHAR(10) NOT NULL,
    Amenity NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_RoomAmenity
        PRIMARY KEY (RoomNumber, Amenity),

    CONSTRAINT FK_RoomAmenity_Room
        FOREIGN KEY (RoomNumber)
        REFERENCES Room(RoomNumber)
);


CREATE TABLE Reservation
(
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    BookingDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ReservationStatus NVARCHAR(50) NOT NULL,
    NumberOfChildren INT NOT NULL DEFAULT 0,
    NumberOfAdults INT NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,

    CONSTRAINT CK_Reservation_Dates
        CHECK (CheckOutDate > CheckInDate)
);


CREATE TABLE ReservationRoom
(
    ReservationID INT NOT NULL,
    RoomNumber NVARCHAR(10) NOT NULL,

    CONSTRAINT PK_ReservationRoom
        PRIMARY KEY (ReservationID, RoomNumber),

    CONSTRAINT FK_ReservationRoom_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationRoom_Room
        FOREIGN KEY (RoomNumber)
        REFERENCES Room(RoomNumber)
);


CREATE TABLE Service
(
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL,
    Charge DECIMAL(10,2) NOT NULL,
    StaffID INT NOT NULL,
    RequestDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Service_Staff
        FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
);


CREATE TABLE ReservationService
(
    ReservationID INT NOT NULL,
    ServiceID INT NOT NULL,

    CONSTRAINT PK_ReservationService
        PRIMARY KEY (ReservationID, ServiceID),

    CONSTRAINT FK_ReservationService_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationService_Service
        FOREIGN KEY (ServiceID)
        REFERENCES Service(ServiceID)
);


CREATE TABLE Guest
(
    GuestID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Nationality NVARCHAR(100) NULL,
    PassportNumber NVARCHAR(50) NOT NULL UNIQUE,
    DateOfBirth DATE NOT NULL
);


CREATE TABLE GuestContactDetail
(
    GuestID INT NOT NULL,
    ContactDetails NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_GuestContactDetail
        PRIMARY KEY (GuestID, ContactDetails),

    CONSTRAINT FK_GuestContactDetail_Guest
        FOREIGN KEY (GuestID)
        REFERENCES Guest(GuestID)
);


CREATE TABLE ReservationGuest
(
    ReservationID INT NOT NULL,
    GuestID INT NOT NULL,

    CONSTRAINT PK_ReservationGuest
        PRIMARY KEY (ReservationID, GuestID),

    CONSTRAINT FK_ReservationGuest_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationGuest_Guest
        FOREIGN KEY (GuestID)
        REFERENCES Guest(GuestID)
);


CREATE TABLE Payment
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    Method NVARCHAR(50) NOT NULL,
    Date DATETIME2 NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    ConfirmationNumber NVARCHAR(50) NULL
);


CREATE TABLE ReservationPayment
(
    ReservationID INT NOT NULL,
    PaymentID INT NOT NULL,

    CONSTRAINT PK_ReservationPayment
        PRIMARY KEY (ReservationID, PaymentID),

    CONSTRAINT FK_ReservationPayment_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationPayment_Payment
        FOREIGN KEY (PaymentID)
        REFERENCES Payment(PaymentID)
);