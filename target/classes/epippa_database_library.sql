-- Municipal library system database
-- Introduction to Databases project
-- Emanuele Pippa, Student ID [20009]

DROP TABLE IF EXISTS Authorizes CASCADE;
DROP TABLE IF EXISTS InternalLoan CASCADE;
DROP TABLE IF EXISTS ExternalLoan CASCADE;
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
    librarianID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL
);

CREATE TABLE Writer (
    name VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    PRIMARY KEY (name, lastName)
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
    copies INTEGER CHECK (copies >= 0)
);

CREATE TABLE PublishedBy (
    bookISBN VARCHAR(13) PRIMARY KEY REFERENCES Book(ISBN) ON DELETE CASCADE,
    publisherName VARCHAR(50) REFERENCES Publisher(name) ON DELETE CASCADE,
    edition VARCHAR(50) NOT NULL
);

CREATE TABLE BelongsTo (
    bookISBN VARCHAR(13) REFERENCES Book(ISBN) ON DELETE CASCADE,
    categoryName VARCHAR(50) REFERENCES Category(name) ON DELETE CASCADE,
    PRIMARY KEY (bookISBN, categoryName)
);

CREATE TABLE WrittenBy (
    bookISBN VARCHAR(13) REFERENCES Book(ISBN) ON DELETE CASCADE,
    writerName VARCHAR(50) NOT NULL,
    writerLastName VARCHAR(50) NOT NULL,
    FOREIGN KEY (writerName, writerLastName) REFERENCES Writer(name, lastName) ON DELETE CASCADE,
    PRIMARY KEY (bookISBN, writerName, writerLastName)
);

DROP TYPE IF EXISTS membership; --remove and create again type membership
CREATE TYPE membership AS ENUM ('standard', 'premium');

DROP TYPE IF EXISTS loan_status; --remove and create again type loan_status
CREATE TYPE loan_status AS ENUM ('available', 'full');

CREATE TABLE Client (
    clientID SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    age INTEGER CHECK (age > 0),
    cityOfBirth VARCHAR(50),
    membershipType membership NOT NULL,
    loanStatus loan_status NOT NULL DEFAULT 'available',
    maxBookPerTime INTEGER CHECK (maxBookPerTime > 0 AND maxBookPerTime <= 5)
);

CREATE TABLE Phone (
    clientID INTEGER REFERENCES Client(clientID) ON DELETE CASCADE,
    phoneNumber VARCHAR(15),
    PRIMARY KEY (clientID, phoneNumber)
);

-- Function: max 2 phone numbers
CREATE OR REPLACE FUNCTION check_max_phones()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Phone WHERE clientID = NEW.clientID) > 2 THEN
        RAISE EXCEPTION 'Maximum 2 phone numbers per client';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER maximum_phones
BEFORE INSERT OR UPDATE ON Phone
FOR EACH ROW EXECUTE FUNCTION check_max_phones();

CREATE TABLE Student (
    clientID INTEGER REFERENCES Client(clientID) ON DELETE CASCADE,
    studentID VARCHAR(20) NOT NULL,
    universityCode VARCHAR(10) NOT NULL,
    courseOfStudy VARCHAR(50) NOT NULL,
    enrollmentYear INTEGER NOT NULL,
    PRIMARY KEY (clientID, studentID, universityCode)
);

CREATE TABLE Worker (
    clientID INTEGER PRIMARY KEY REFERENCES Client(clientID) ON DELETE CASCADE,
    jobTitle VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE TABLE Loan (
    startDate DATE NOT NULL,
    bookISBN VARCHAR(13) REFERENCES Book(ISBN) ON DELETE CASCADE,
    clientID INTEGER REFERENCES Client(clientID) ON DELETE CASCADE,
    endDate DATE NOT NULL,
    returnDate DATE,
    returnNotes TEXT,
    PRIMARY KEY (startDate, bookISBN, clientID)
);

-- Function: check if a book is available before creating a loan
CREATE OR REPLACE FUNCTION check_book_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT copies FROM Book WHERE ISBN = NEW.bookISBN) < 1 THEN
        RAISE EXCEPTION 'No copies available for this book';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: enforce book availability before creating a loan
CREATE TRIGGER enforce_book_availability
BEFORE INSERT ON Loan
FOR EACH ROW EXECUTE FUNCTION check_book_availability();

CREATE TABLE InternalLoan (
    startDate DATE NOT NULL,
    bookISBN VARCHAR(13) NOT NULL,
    clientID INTEGER NOT NULL,
    timeLimit INTEGER CHECK (timeLimit = 15),
    FOREIGN KEY (startDate, bookISBN, clientID) REFERENCES Loan(startDate, bookISBN, clientID) ON DELETE CASCADE,
    PRIMARY KEY (startDate, bookISBN, clientID)
);

CREATE TABLE ExternalLoan (
    startDate DATE NOT NULL,
    bookISBN VARCHAR(13) NOT NULL,
    clientID INTEGER NOT NULL,
    dueDate DATE NOT NULL,
    allowedExtension BOOLEAN DEFAULT FALSE,
    amountOfFees DECIMAL(10,2) CHECK (amountOfFees >= 0),
    CONSTRAINT loan_duration CHECK (dueDate <= startDate + INTERVAL '30 days'),
    FOREIGN KEY (startDate, bookISBN, clientID) REFERENCES Loan(startDate, bookISBN, clientID) ON DELETE CASCADE,
    PRIMARY KEY (startDate, bookISBN, clientID)
);

CREATE TABLE Authorizes (
    librarianID INTEGER REFERENCES Librarian(librarianID) ON DELETE CASCADE,
    startDate DATE NOT NULL,
    bookISBN VARCHAR(13) NOT NULL,
    clientID INTEGER NOT NULL,
    acceptance BOOLEAN NOT NULL,
    FOREIGN KEY (startDate, bookISBN, clientID) REFERENCES Loan(startDate, bookISBN, clientID) ON DELETE CASCADE,
    PRIMARY KEY (librarianID, startDate, bookISBN, clientID)
);

-- update book's copies when a copy is borrowed
CREATE OR REPLACE FUNCTION update_book_copies()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.acceptance = TRUE THEN
        UPDATE Book SET copies = copies - 1 
        WHERE ISBN = NEW.bookISBN AND copies > 0;
        
        UPDATE Client SET loanStatus = 'full'
        WHERE clientID = NEW.clientID AND (
            SELECT COUNT(*) FROM Loan 
            WHERE clientID = NEW.clientID AND returnDate IS NULL
        ) >= (SELECT maxBookPerTime FROM Client WHERE clientID = NEW.clientID);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to manage the book's copies
CREATE TRIGGER manage_book_copies
AFTER INSERT OR UPDATE ON Authorizes
FOR EACH ROW EXECUTE FUNCTION update_book_copies();

-- Function: update loan status when a book is returned
CREATE OR REPLACE FUNCTION update_loan_status_on_return()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.returnDate IS NOT NULL THEN
        UPDATE Client SET loanStatus = 'available'
        WHERE clientID = NEW.clientID AND (
            SELECT COUNT(*) FROM Loan 
            WHERE clientID = NEW.clientID AND returnDate IS NULL
        ) < (SELECT maxBookPerTime FROM Client WHERE clientID = NEW.clientID);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: manage loan status when a book is returned
CREATE TRIGGER manage_loan_status_on_return
AFTER UPDATE ON Loan
FOR EACH ROW EXECUTE FUNCTION update_loan_status_on_return();