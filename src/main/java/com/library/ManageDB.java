package com.library;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.Scanner;

public class ManageDB {   //manages the database initialization and the operations on the Loan and Authorizes tables

    //Initialize the database connection by executing the SQL files to create the schema and populate it with initial data
    public static void initDB(Connection conn) {
        executeSQLFile(conn, "src/main/sql/epippa_database_library.sql");   //Create the database schema
        executeSQLFile(conn, "src/main/sql/populate_database.sql");     //Populate the database with initial data
    }
    private static void executeSQLFile(Connection conn, String filePath) {
        //upload SQL files
        try ( 
            Scanner sc = new Scanner(new FileInputStream(filePath), StandardCharsets.UTF_8.name());
            Statement stmt = conn.createStatement()    //Statement to execute the SQL commands
        ) {
            String sql = sc.useDelimiter("\\A").next();     //read the file
            stmt.execute(sql);
            System.out.println("DB initialized!");

        } catch (Exception e) {
            System.err.println("DB initialization error");
        }
    }

    //Close the database connection and the scanner
    public static void closeStuff(Connection c, Scanner s) {
        try {
            if (c != null && !c.isClosed()) {
                c.close();
            }
        } catch (SQLException e) {
            System.err.println("Closing error");
        }
        if (s != null) {
            s.close();
        }
    }

    //Inserts a loan into Loan Table and an authorization into Authorizes Table
    public static void insertLoanWithAuthorization(Connection conn, Loan loan, int librarianId, boolean acceptance) {
        String insertLoan = "INSERT INTO Loan(startDate, book, client, endDate, loanStatus) VALUES (?, ?, ?, ?, ?)";
        String insertAuthorizes = "INSERT INTO Authorizes(librarian, startDate, book, client, acceptance) VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement loanStmt = conn.prepareStatement(insertLoan);
             PreparedStatement authStmt = conn.prepareStatement(insertAuthorizes)) {
            
            //Set parameters for the loan
            loanStmt.setDate(1, loan.getStartDate());
            loanStmt.setString(2, loan.getBookISBN());
            loanStmt.setInt(3, loan.getClientId());
            loanStmt.setDate(4, loan.getEndDate());
            loanStmt.setString(5, loan.getLoanStatus());

            //Set parameters for the authorization
            authStmt.setInt(1, librarianId);
            authStmt.setDate(2, loan.getStartDate());
            authStmt.setString(3, loan.getBookISBN());
            authStmt.setInt(4, loan.getClientId());
            authStmt.setBoolean(5, acceptance);

            //Execute both statements in a transaction
            conn.setAutoCommit(false);  //Disable auto-commit tu use multiple transactions as a single one
            loanStmt.executeUpdate();   //1° insert (Loan)
            authStmt.executeUpdate();   //2° insert (Authorizes)
            conn.commit();      //Commit the transaction if both inserts are successful, otherwise rollback

            System.out.println("Loan and authorization have been successfully inserted");

        } catch (SQLException e) {
            try {   //Rollback in case of error: if one transaction fails, abort all operations
                conn.rollback();
            } catch (SQLException ex) {     //Handle rollback failure
                System.err.println("Rollback failed: " + ex.getMessage());
            }
            System.err.println("Error inserting loan and authorization: " + e.getMessage());
        } finally {
            try {    //Restore the normal auto-commit behavior
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    //Record the return of a book
    //update the Loan table with the return date and notes
    //and set the loan status to 'returned'
    public static void returnBook(Connection conn, Date startDate, String bookISBN, int clientId, Date returnDate, String notes) {
        //Enable the trigger to update the number of availableCopies in the Book table
        String updateLoan = "UPDATE Loan SET returnDate = ?, returnNotes = ?, loanStatus = 'returned' WHERE startDate = ? AND book = ? AND client = ?";

        try (PreparedStatement stmt = conn.prepareStatement(updateLoan)) {
            stmt.setDate(1, returnDate);
            stmt.setString(2, notes);
            stmt.setDate(3, startDate);
            stmt.setString(4, bookISBN);
            stmt.setInt(5, clientId);

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                System.out.println("Book returned successfully.");
            } else {
                System.out.println("No matching loan found.");
            }

        } catch (SQLException e) {
            System.err.println("Error returning book: " + e.getMessage());
        }
    }
}
