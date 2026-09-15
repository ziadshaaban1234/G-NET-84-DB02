-- ============================================================
-- Hotel Reservation Management System - Relational Mapping
-- Mapped from the provided ER diagram (Chen notation)
-- Dialect: T-SQL (SQL Server)
-- ============================================================

-- ManagerStaffId's FK to Staff is added after Staff exists below (circular reference: a
-- hotel's manager is a staff member, and every staff member works at one hotel).
CREATE TABLE Hotel (
    HotelId         INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    StarRating      INT NOT NULL,
    ContactNumber   NVARCHAR(20) NULL,
    Address         NVARCHAR(250) NOT NULL,
    City            NVARCHAR(100) NOT NULL,
    ManagerStaffId  INT NULL,
    CONSTRAINT CK_Hotel_StarRating CHECK (StarRating BETWEEN 1 AND 5)
);

-- Work: Hotel (1) -- Staff (M)
CREATE TABLE Staff (
    StaffId     INT IDENTITY(1,1) PRIMARY KEY,
    FullName    NVARCHAR(150) NOT NULL,
    Position    NVARCHAR(50) NOT NULL,
    Salary      DECIMAL(10, 2) NOT NULL,
    HotelId     INT NOT NULL,
    CONSTRAINT FK_Staff_Hotel FOREIGN KEY (HotelId)
        REFERENCES Hotel (HotelId)
);

-- Manage: Hotel (1) -- Staff (1)
ALTER TABLE Hotel
    ADD CONSTRAINT FK_Hotel_Manager FOREIGN KEY (ManagerStaffId)
        REFERENCES Staff (StaffId);

-- Contains: Hotel (1) -- Room (M)
CREATE TABLE Room (
    RoomNumber          NVARCHAR(10) PRIMARY KEY,
    RoomType            NVARCHAR(50) NOT NULL,
    Capacity            INT NOT NULL,
    DailyRate           DECIMAL(10, 2) NOT NULL,
    AvailabilityStatus  NVARCHAR(50) NOT NULL,
    HotelId             INT NOT NULL,
    CONSTRAINT FK_Room_Hotel FOREIGN KEY (HotelId)
        REFERENCES Hotel (HotelId)
);

-- Amenity is a multivalued attribute of Room, so it becomes its own table.
CREATE TABLE RoomAmenity (
    RoomNumber  NVARCHAR(10) NOT NULL,
    Amenity     NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_RoomAmenity PRIMARY KEY (RoomNumber, Amenity),
    CONSTRAINT FK_RoomAmenity_Room FOREIGN KEY (RoomNumber)
        REFERENCES Room (RoomNumber)
);

CREATE TABLE Guest (
    GuestId         INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(150) NOT NULL,
    Nationality     NVARCHAR(100) NULL,
    PassportNumber  NVARCHAR(50) NOT NULL UNIQUE,
    DateOfBirth     DATE NOT NULL
);

-- ContactDetails is a multivalued attribute of Guest, so it becomes its own table.
CREATE TABLE GuestContactDetail (
    GuestId         INT NOT NULL,
    ContactDetail   NVARCHAR(150) NOT NULL,
    CONSTRAINT PK_GuestContactDetail PRIMARY KEY (GuestId, ContactDetail),
    CONSTRAINT FK_GuestContactDetail_Guest FOREIGN KEY (GuestId)
        REFERENCES Guest (GuestId)
);

CREATE TABLE Reservation (
    ReservationId       INT IDENTITY(1,1) PRIMARY KEY,
    CheckInDate         DATE NOT NULL,
    CheckOutDate        DATE NOT NULL,
    TotalPrice          DECIMAL(10, 2) NOT NULL,
    NumberOfAdults      INT NOT NULL,
    NumberOfChildren    INT NOT NULL DEFAULT 0,
    BookingDate         DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ReservationStatus   NVARCHAR(50) NOT NULL,
    CONSTRAINT CK_Reservation_Dates CHECK (CheckOutDate > CheckInDate)
);

-- Books: Room (M) -- Reservation (M)
CREATE TABLE ReservationRoom (
    ReservationId   INT NOT NULL,
    RoomNumber      NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_ReservationRoom PRIMARY KEY (ReservationId, RoomNumber),
    CONSTRAINT FK_ReservationRoom_Reservation FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT FK_ReservationRoom_Room FOREIGN KEY (RoomNumber)
        REFERENCES Room (RoomNumber)
);

-- Make: Guest (M) -- Reservation (M)
CREATE TABLE ReservationGuest (
    ReservationId   INT NOT NULL,
    GuestId         INT NOT NULL,
    CONSTRAINT PK_ReservationGuest PRIMARY KEY (ReservationId, GuestId),
    CONSTRAINT FK_ReservationGuest_Reservation FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT FK_ReservationGuest_Guest FOREIGN KEY (GuestId)
        REFERENCES Guest (GuestId)
);

-- Provide: Staff (1) -- Service (M)
CREATE TABLE Service (
    ServiceId       INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName     NVARCHAR(100) NOT NULL,
    RequestDate     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Charge          DECIMAL(10, 2) NOT NULL,
    StaffId         INT NOT NULL,
    CONSTRAINT FK_Service_Staff FOREIGN KEY (StaffId)
        REFERENCES Staff (StaffId)
);

-- Request: Service (M) -- Reservation (M)
CREATE TABLE ReservationService (
    ReservationId   INT NOT NULL,
    ServiceId       INT NOT NULL,
    CONSTRAINT PK_ReservationService PRIMARY KEY (ReservationId, ServiceId),
    CONSTRAINT FK_ReservationService_Reservation FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT FK_ReservationService_Service FOREIGN KEY (ServiceId)
        REFERENCES Service (ServiceId)
);

CREATE TABLE Payment (
    PaymentId           INT IDENTITY(1,1) PRIMARY KEY,
    ConfirmationNumber  NVARCHAR(50) NULL,
    Method              NVARCHAR(50) NOT NULL,
    Amount              DECIMAL(10, 2) NOT NULL,
    PaymentDate         DATETIME2 NOT NULL
);

-- Have: Payment (M) -- Reservation (M)
CREATE TABLE ReservationPayment (
    ReservationId   INT NOT NULL,
    PaymentId       INT NOT NULL,
    CONSTRAINT PK_ReservationPayment PRIMARY KEY (ReservationId, PaymentId),
    CONSTRAINT FK_ReservationPayment_Reservation FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT FK_ReservationPayment_Payment FOREIGN KEY (PaymentId)
        REFERENCES Payment (PaymentId)
);
