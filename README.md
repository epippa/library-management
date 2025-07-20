@epippa_database_library

# Municipal Library Management System

> **License**: [MIT](LICENSE)


This project implements a **management system for a physical municipal library**, developed in **Java** with **PostgreSQL**. The system supports:

- Book **registration**, **search**, and **copy management**
- **Loan handling**, with **authorizations** by librarians
- Management of **clients**, including **students** and **workers**
- Classification of books by **category**, **author**, and **publisher**
- Automatic enforcement of business rules via triggers (e.g., book availability, phone number limits)


## Use of Maven for:
- **Automatic Management of the dependencies** (automatic download of the needed JAR)
- **Standardized Build** (Same commands for all the projects)
- **Simplified Packaging** (it creates a JAR with all the necessary)
- **Clear Structure of the project** (organized filess)
- **Integration with the IDE**
- **Easy addition of plugins** (testing, analisi codice, etc.)

## To work without Maven
The application needs:
1. Manual download of JDBC PostgreSQL drivers
2. Manual compilazion using `javac`
3. Manual management of the classpath
4. Manual packaging of the JAR
---
# Project Stucture
```bash
library-management/
├── src/main/java/com/library
│   ├── App.java # Main interface: user menu and application flow
│   ├── Book.java # Book entity: ISBN, title, year, copies
│   ├── BookManager.java # DB operations for books (search, add, update)
│   ├── ManageDB.java # DB setup and utility methods
│   └── Loan.java # DB operations for loans
│
├── src/main/sql/
|   ├── epippa_database_library.sql
│   └── populate_database.sql
│
├── pom.xml
└── README.md
```
#  Execution (with Maven):

## Prerequisites
Before running the application, make sure to:
- Run the PostgreSQL server → eg. via pgAdmin
- Create a database named epippa_library_management
- Ensure the credentials in App.java (USER, PASSWORD) match your local PostgreSQL configuration
- Have Maven installed and working

## Compile and execute the Application
In the terminal from the project root (where `pom.xml` is located):
```bash
 mvn clean compile exec:java
```
## Package a Runnable JAR (in target/)
```bash
mvn package
java -jar target/library-1.0-SNAPSHOT.jar
```
---

# Description
**Menu Options:**
1. `Search books` → search by partial title (case-insensitive)
2. `Add book` → add a new book (ISBN, title, year, copies)
3. `Change copies` → update the number of copies for a book
4. `EXIT` → exit the program

Insert the number, not the word, to choose an option.

**The application handles:**
- Failed DB Connections
- Invalid User Input
- Duplicated ISBN
- Research without results
- Wrong Numerical Formats

# Classes Descrition

## App.java
Manages the main application loop, connects to the database, and handles user input/output. It delegates actions to `BookManager`, `ManageDB`, and related classes.

## Book.java
- Simple model class representing a book with:
    - ISBN
    - Title
    - Year of publication
    - Number of copies
- Includes a custom `toString()` for pretty printing.

## BookManager.java
Handles book-related database operations. All queries are prepared statements to prevent SQL injection.

Methods:
- `searchBooks(String title)` → finds books by title
- `addNewBook(String isbn, String title, int year, int copies)` → inserts a new book
- `updateCopies(String isbn, int copies)` → updates total copies

## ManageDB.java
Provides utilities for managing the database:
- `initDB(Connection)` → loads and executes the full SQL schema from file
- `closeStuff(Connection, Scanner)` → safely closes resources
- `insertLoanWithAuthorization(...)` → inserts a loan and associated authorization in a single transaction
- `returnBook(...)` → registers a book return and updates loan status

## Loan.java
Model class for a loan, with standard getters/setters:

`startDate`, `endDate`
`bookISBN`, `clientId`
`returnDate`, `returnNotes`, `loanStatus`

If extended, can support:
- Inserting loans
- Listing loans by client

# Pre-populate the database
The file `populate_database.sql` is automatically loaded and executed by `ManageDB.java` after the database schema (`epippa_database_library.sql`) is created.

This ensures the system starts with some data:
- Books
- Clients
- Loans
- Authorizations
- Writers
- Librarians

---

## Autore

**Emanuele Pippa**  
Studente di Informatica presso la Libera Università di Bolzano  
GitHub: [epippa](https://github.com/epippa)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
