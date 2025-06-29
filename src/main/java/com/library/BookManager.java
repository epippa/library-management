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
        String query="SELECT isbn,title,yearofpublication,copies FROM book WHERE title ILIKE ?";
        try (PreparedStatement stmt=dbConn.prepareStatement(query)) {
            stmt.setString(1,"%" + title + "%");    // '%' is used for partial match: any characters before or after the title
            
            try(ResultSet rs=stmt.executeQuery()) {
                List<Book> results=new ArrayList<>();
                //For each result, create a Book object and add it to the list
                while(rs.next()) {
                    results.add(new Book(
                        rs.getString("isbn"),
                        rs.getString("title"),
                        rs.getInt("yearofpublication"),
                        rs.getInt("copies")
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
    public void addNewBook(String isbn,String title,int year,int copies) {
        String query="INSERT INTO Book (isbn,title,yearofpublication,copies, availableCopies) VALUES (?,?,?,?,?)";
        try(PreparedStatement stmt=dbConn.prepareStatement(query)) {
            stmt.setString(1,isbn);
            stmt.setString(2,title); 
            stmt.setInt(3,year);
            stmt.setInt(4,copies);
            stmt.setInt(5,copies);  //availableCopies initally setted = copies
            
            int rows=stmt.executeUpdate();  //Executes the prepared INSERT statement and returns how many rows were affected
            System.out.println(rows+" book added!");    //If rows>0, the book was added successfully
        } catch(SQLException e) {
            System.err.println("Add error");
        }
    }

    //update the total number of copies of a book owned by the library
    public void updateCopies(String isbn,int copies) {
        String query="UPDATE book SET copies=? WHERE isbn=?";
        try(PreparedStatement stmt=dbConn.prepareStatement(query)) {
            stmt.setInt(1,copies);
            stmt.setString(2,isbn);
            
            int rows=stmt.executeUpdate();
            if(rows>0) {
                System.out.println("Updated!");
            } else {
                System.out.println("ISBN not found");
            }
        } catch(SQLException e) {
            System.err.println("Update failed");
        }
    }
}