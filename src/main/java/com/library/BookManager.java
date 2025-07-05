/*
 * This file is part of the Municipal Library Management System.
 * Copyright (c) 2025 Emanuele Pippa
 * Licensed under the MIT License. See the LICENSE file for details.
 */

package com.library;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookManager {     //manages the SQL operations about the Book table
    private Connection dbConn;  //Enable the Database connection

    //inizialization with database connection
    public BookManager(Connection conn) {
        this.dbConn=conn;   
    }

    //searches book by title (case-insensitive -> ILIKE)
     public void searchBooks(String title) {
        String query = "SELECT isbn, title, yearofpublication, copies, availableCopies, edition FROM book WHERE title ILIKE ?";
        try (PreparedStatement stmt = dbConn.prepareStatement(query)) {
            stmt.setString(1, "%" + title + "%");    //'%' is used for partial match: any characters before or after the title
            
            try (ResultSet rs = stmt.executeQuery()) {
                List<Book> results = new ArrayList<>();
                //For each result, create a Book object and add it to the list
                while (rs.next()) {
                    results.add(new Book(
                        rs.getString("isbn"),
                        rs.getString("title"),
                        rs.getInt("yearofpublication"),
                        rs.getInt("copies"),
                        rs.getInt("availableCopies"),
                        rs.getInt("edition")
                    ));
                }
                
                if(results.isEmpty()) {
                    System.out.println("\nNo books found");
                } else {
                    results.forEach(System.out::println);
                }
            }
        } catch(SQLException e) {
            System.err.println("Search failed");
        }
    }

    //Add new book to database
    public void addNewBook(String isbn,String title,int year,int copies, int edition) {
        String query="INSERT INTO Book (isbn,title,yearofpublication,copies,availableCopies,edition) VALUES (?,?,?,?,?,?)";
        try(PreparedStatement stmt=dbConn.prepareStatement(query)) {
            stmt.setString(1,isbn);
            stmt.setString(2,title); 
            stmt.setInt(3,year);
            stmt.setInt(4,copies);
            stmt.setInt(5,copies);  //availableCopies initally setted = copies
            stmt.setInt(6, edition);
            
            int rows=stmt.executeUpdate();  //Executes the prepared INSERT statement and returns how many rows were affected
            System.out.println(rows+" book added!");    //If rows>0, the book was added successfully
        } catch(SQLException e) {
            System.err.println("Add error");
        }
    }

    //update the number of available copies of a book
    public void updateAvailableCopies(String isbn, int available) {
        String query = "UPDATE book SET availableCopies = ? WHERE isbn = ?";
        try (PreparedStatement stmt = dbConn.prepareStatement(query)) {
            stmt.setInt(1, available);
            stmt.setString(2, isbn);

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                System.out.println("Available copies updated!");
            } else {
                System.out.println("ISBN not found");
            }
        } catch (SQLException e) {
            System.err.println("Update failed");
        }
    }
}
