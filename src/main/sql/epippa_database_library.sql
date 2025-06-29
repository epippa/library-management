-- 
-- This file is part of the Municipal Library Management System.
-- Copyright (c) 2025 Emanuele Pippa
-- Licensed under the MIT License. See the LICENSE file for details.
--

DROP TABLE IF EXISTS Authorizes CASCADE;
DROP TABLE IF EXISTS Internal CASCADE;
DROP TABLE IF EXISTS External CASCADE;
DROP TABLE IF EXISTS Loan CASCADE;
DROP TABLE IF EXISTS Phone CASCADE;
DROP TABLE IF EXISTS Student CASCADE;
DROP TABLE IF EXISTS Worker CASCADE;
DROP TABLE IF EXISTS Client CASCADE;
DROP TABLE IF EXISTS WrittenBy CASCADE;
DROP TABLE IF EXISTS BelongsTo CASCADE;
DROP TABLE IF EXISTS PublishedBy CASCADE;
DROP TABLE IF EXISTS Book CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Publisher CASCADE;
DROP TABLE IF EXISTS Writer CASCADE;
DROP TABLE IF EXISTS Librarian CASCADE;

CREATE TABLE Librarian (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL
);

CREATE TABLE Writer (
    name VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    PRIMARY KEY (name, lastname)
);

CREATE TABLE Publisher (
    name VARCHAR(50) PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    foundationYear INTEGER
);

CREATE TABLE Category (
    name VARCHAR(50) PRIMARY KEY,
    rank INTEGER CHECK (rank BETWEEN 1 AND 10)
);

CREATE TABLE Book (
    ISBN VARCHAR(13) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    yearOfPublication INTEGER,
    copies INTEGER CHECK (copies >= 0),
    availableCopies INTEGER CHECK (availableCopies <= copies) -- To avoid availableCopies < 0
);

CREATE TABLE PublishedBy (
    book VARCHAR(13) PRIMARY KEY REFERENCES Book(ISBN) ON DELETE CASCADE,
    publisher VARCHAR(50) REFERENCES Publisher(name) ON DELETE CASCADE,
    edition VARCHAR(50) NOT NULL
);

CREATE TABLE BelongsTo (
    book VARCHAR(13) REFERENCES Book(ISBN) ON DELETE CASCADE,
    category VARCHAR(50) REFERENCES Category(name) ON DELETE CASCADE,
    PRIMARY KEY (book, category)
);

CREATE TABLE WrittenBy (
    book VARCHAR(13) REFERENCES Book(ISBN) ON DELETE CASCADE,
    writerName VARCHAR(50),
    writerLastname VARCHAR(50),
    PRIMARY KEY (book, writerName, writerLastname),
    FOREIGN KEY (writerName, writerLastname) REFERENCES Writer(name, lastname) ON DELETE CASCADE
);

--remove and create again type membership
DROP TYPE IF EXISTS membership;
CREATE TYPE membership AS ENUM ('standard', 'premium');

CREATE TABLE Client (
    clientId SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    age INTEGER CHECK (age > 0),
    cityOfBirth VARCHAR(50),
    membershipType membership NOT NULL,
    maxBookPerTime INTEGER CHECK (maxBookPerTime > 0 AND maxBookPerTime <= 5)
);

CREATE TABLE Phone (
    client INTEGER REFERENCES Client(clientId) ON DELETE CASCADE,
    phone VARCHAR(15) NOT NULL,
    PRIMARY KEY (client, phone)
);

CREATE OR REPLACE FUNCTION check_max_phones()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Phone WHERE client = NEW.client) >= 2 THEN
        RAISE EXCEPTION 'Maximum 2 phone numbers per client';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER maximum_phones
BEFORE INSERT OR UPDATE ON Phone
FOR EACH ROW EXECUTE FUNCTION check_max_phones();

CREATE TABLE Student (
    client INTEGER PRIMARY KEY REFERENCES Client(clientId) ON DELETE CASCADE,
    studentId VARCHAR(20),
    universityCode VARCHAR(10),
    courseOfStudy VARCHAR(50),
    enrollmentYear INTEGER
);

CREATE TABLE Worker (
    client INTEGER PRIMARY KEY REFERENCES Client(clientId) ON DELETE CASCADE,
    jobTitle VARCHAR(50),
    department VARCHAR(50)
);

CREATE TABLE Loan (
    startDate DATE NOT NULL,
    book VARCHAR(13) NOT NULL REFERENCES Book(ISBN) ON DELETE CASCADE,
    client INTEGER NOT NULL REFERENCES Client(clientId) ON DELETE CASCADE,
    endDate DATE NOT NULL,
    returnDate DATE,
    returnNotes TEXT,
    loanStatus VARCHAR(20) CHECK (loanStatus IN ('pending', 'active', 'returned', 'expired')),
    PRIMARY KEY (startDate, book, client)
);

CREATE OR REPLACE FUNCTION check_book_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT availableCopies FROM Book WHERE ISBN = NEW.book) < 1 THEN
        RAISE EXCEPTION 'No available copies for this book';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: enforce book availability before creating a loan
CREATE TRIGGER enforce_book_availability
BEFORE INSERT ON Loan
FOR EACH ROW EXECUTE FUNCTION check_book_availability();

CREATE TABLE Internal (
    startDate DATE NOT NULL,
    book VARCHAR(13) NOT NULL,
    client INTEGER NOT NULL,
    timeLimit INTEGER CHECK (timeLimit = 15),
    PRIMARY KEY (startDate, book, client),
    FOREIGN KEY (startDate, book, client) REFERENCES Loan(startDate, book, client) ON DELETE CASCADE
);

CREATE TABLE External (
    startDate DATE NOT NULL,
    book VARCHAR(13) NOT NULL,
    client INTEGER NOT NULL,
    dueDate DATE NOT NULL,
    allowedExtension BOOLEAN DEFAULT FALSE,
    amountOfFees DECIMAL(10,2) DEFAULT 0 CHECK (amountOfFees >= 0),
    PRIMARY KEY (startDate, book, client),
    FOREIGN KEY (startDate, book, client) REFERENCES Loan(startDate, book, client) ON DELETE CASCADE
);

CREATE TABLE Authorizes (
    librarian INTEGER NOT NULL REFERENCES Librarian(id) ON DELETE CASCADE,
    startDate DATE NOT NULL,
    book VARCHAR(13) NOT NULL,
    client INTEGER NOT NULL,
    acceptance BOOLEAN NOT NULL,
    PRIMARY KEY (startDate, book, client),
    FOREIGN KEY (startDate, book, client) REFERENCES Loan(startDate, book, client)
);

-- Update availableCopies after authorization
CREATE OR REPLACE FUNCTION update_book_copies()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.acceptance = TRUE THEN
        UPDATE Book SET availableCopies = availableCopies - 1 
        WHERE ISBN = NEW.book AND availableCopies > 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to manage the book's copies
CREATE TRIGGER manage_book_copies
AFTER INSERT OR UPDATE ON Authorizes
FOR EACH ROW EXECUTE FUNCTION update_book_copies();

-- Function: update loan status when a book is returned
-- (increase availableCopies in Book table)
CREATE OR REPLACE FUNCTION update_loan_on_return()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.returnDate IS NOT NULL THEN
        UPDATE Book SET availableCopies = availableCopies + 1
        WHERE ISBN = NEW.book;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: manage loan status when a book is returned
CREATE TRIGGER restore_book_copy
AFTER UPDATE ON Loan
FOR EACH ROW EXECUTE FUNCTION update_loan_on_return();