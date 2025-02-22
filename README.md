@epippa_database_library
# System to manage a municipal library

This is a Java application to manage a physical library, with support for books, loan and clients.

## Use of Maven for:
- **Automatic Management of the dependencies** (automatic download of the needed JAR)
- **Standardized Build** (Same commands for all the projects)
- **Simplified Packaging** (it creates a JAR with all the necessary)
- **Clear Structure of the project** (organized filess)
- **Integration with the IDE**
- **Easy addition of plugins** (testing, analisi codice, etc.)

**To work without Maven**, the application needs:
1. Manual download of JDBC PostgreSQL drivers
2. Manual compilazion using `javac`
3. Manual management of the classpath
4. Manual packaging of the JAR

## Project Stucture
library-management/
├── src/main/java/com/library
│        |              ├──`App`.java           (Interactive menu and management of the application)
│        |              ├──`Book`.java          (Represents a book: ISBN, title, Year, Copies)
│        |              ├──`BookManager`.java   (Manages the operation of the database: insert/update/search)
│        |              └──`ManageDB`.java      (Initializes tables and manages connections/closures)
|        └── sql/
|             └── epippa_database_library.sql
└── pom.xml

## 🚀 Execution (with Maven):

# Compile and execute
mvn clean compile exec:java

# Crea JAR eseguibile (in target/)
mvn package
java -jar target/library-1.0-SNAPSHOT.jar

------------------------------------------------------------------------------------------------

**Comamands:**
Search books per title
Add a new book (with all the details)
Modify the number of available copies, through ISBN
Exit from the application

**The application manages:**
Failed DB Connections
Invalid User Input
Duplicated ISBN
Research without results
Wrong Numerical Formats