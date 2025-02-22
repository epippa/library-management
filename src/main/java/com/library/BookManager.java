package com.library;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookManager {     //manages DB operations
    private Connection dbConn;  //Active DB connection

    //inizialization with database connection
    public BookManager(Connection conn) {   //conn = valid sql connection
        this.dbConn=conn;
    }

    //searches book by title (case-insensitive -> ILIKE)
    public void searchBooks(String title) {
        String query="SELECT isbn,title,yearofpublication,copies FROM book WHERE title ILIKE ?";
        try (PreparedStatement stmt=dbConn.prepareStatement(query)) {
            stmt.setString(1,"%" + title + "%");
            
            try(ResultSet rs=stmt.executeQuery()) {
                List<Book> results=new ArrayList<>();
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
        String query="INSERT INTO Book (isbn,title,yearofpublication,copies) VALUES (?,?,?,?)";
        try(PreparedStatement stmt=dbConn.prepareStatement(query)) {  //prepareStatement inserts
            stmt.setString(1,isbn);                    //the following parameters
            stmt.setString(2,title);                   //in order in the ? positions 
            stmt.setInt(3,year);                       //in a secure way: avoid
            stmt.setInt(4,copies);                     //attacks of sql injection
            
            int rows=stmt.executeUpdate();
            System.out.println(rows+" book added!");
        } catch(SQLException e) {
            System.err.println("Add error");
        }
    }

    //updates available copies of a book
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