DELETE FROM Authorizes;
DELETE FROM External;
DELETE FROM Internal;
DELETE FROM Loan;
DELETE FROM Client;
DELETE FROM Librarian;
DELETE FROM Writer;
DELETE FROM Book;

INSERT INTO Book (isbn, title, yearofpublication, copies, availableCopies) VALUES
('9780451524935', '1984', 1949, 5, 5),
('9780439708180', 'Harry Potter', 1997, 3, 3),
('9780307743657', 'The Road', 2006, 7, 7),
('9788804668237', 'Il nome della rosa', 1980, 5, 5),
('9788806227458', 'Se una notte d''inverno un viaggiatore', 1979, 3, 3),
('9788845270527', 'Novecento', 1994, 7, 7);

INSERT INTO Client (name, lastname, age, cityOfBirth, membershipType, maxBookPerTime) VALUES
('Emanuele', 'Pippa', 25, 'Bolzano', 'standard', 3),
('Franchetto', 'Bianchi', 30, 'Roma', 'premium', 5),
('Jonny', 'Gialli', 22, 'Napoli', 'standard', 2);

INSERT INTO Librarian (name, lastname) VALUES
('Giovanni', 'Bianchi'),
('Laura', 'Rossi');

INSERT INTO Writer (name, lastname, nationality) VALUES
('Umberto', 'Eco', 'Italiana'),
('Italo', 'Calvino', 'Italiana'),
('Alessandro', 'Baricco', 'Italiana');

INSERT INTO Loan (startDate, book, client, endDate, loanStatus) VALUES
('2024-02-01', '9780451524935', 1, '2024-03-01', 'active'),
('2024-02-01', '9780439708180', 2, '2024-03-01', 'active'),
('2024-02-01', '9780307743657', 3, '2024-03-01', 'active');

INSERT INTO Authorizes (librarian, startDate, book, client, acceptance) VALUES
(1, '2024-02-01', '9780451524935', 1, TRUE),
(2, '2024-02-01', '9780439708180', 2, TRUE),
(1, '2024-02-01', '9780307743657', 3, TRUE);

INSERT INTO Internal (startDate, book, client, timeLimit) VALUES
('2024-02-01', '9780451524935', 1, 15);

INSERT INTO External (startDate, book, client, dueDate, allowedExtension, amountOfFees) VALUES
('2024-02-01', '9780439708180', 2, '2024-03-01', TRUE, 0.00),
('2024-02-01', '9780307743657', 3, '2024-03-01', FALSE, 2.00);
