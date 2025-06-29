package com.library;

import java.sql.*;
import java.util.Scanner;

public class App {

    //DB connection setting
    private static final String URL="jdbc:postgresql://localhost:5432/epippa_library_management";
    private static final String USER="postgres";
    private static final String PASSWORD="emanuele";

    public static void main(String[] args) {
        Connection conn=null;
        Scanner scan=new Scanner(System.in);
        BookManager bManager=null;

        try {
            conn=DriverManager.getConnection(URL,USER,PASSWORD);
            ManageDB.initDB(conn);
            
            bManager=new BookManager(conn);
            boolean exitFlag=false;
            
            while(!exitFlag) {
                exitFlag=showMenu(scan,bManager);
            }
        } catch(SQLException e) {
            System.err.println("Connection error");
        } finally {
            ManageDB.closeStuff(conn,scan);
        }
    }
    
    //Displays menu and handles user input
    //sc = scanner for the input of the user
    //bm = instance for the database operations
    private static boolean showMenu(Scanner sc, BookManager bm) {
    
        System.out.println("\n=== LIBRARY SYSTEM ===");
        System.out.println("1. Search books");
        System.out.println("2. Add book");
        System.out.println("3. Change copies");
        System.out.println("4. EXIT");
        System.out.print("Choose: ");

        try {
            int opt=Integer.parseInt(sc.nextLine());
            switch(opt) {
                case 1: doSearch(sc,bm); break;
                case 2: addBook(sc,bm); break;
                case 3: updateCopies(sc,bm); break;
                case 4: 
                    System.out.println("Bye!"); 
                    return true;
                default: 
                    System.out.println("Invalid choice!"); 
            }
        } catch(NumberFormatException e) {
            System.out.println("Invalid input");
        }
        return false;
    }

    //Search a book by title
    //sc = scanner for user input
    //bm = instance for search operations
    private static void doSearch(Scanner sc, BookManager bm) {
        System.out.print("\nBook title to search: ");
        String title=sc.nextLine().trim();
        bm.searchBooks(title);
    }

    //Allows to Add a new book to the database
    //sc = scanner for the user input
    //bm = instance for the insertion operations
    private static void addBook(Scanner sc, BookManager bm) {
        try {
            System.out.println("\n=== NEW BOOK ===");
            System.out.print("ISBN (13 numbers): ");
            String isbn=sc.nextLine();
            
            System.out.print("Title: ");
            String title=sc.nextLine();
            
            System.out.print("Year: ");
            int year=Integer.parseInt(sc.nextLine());
            
            System.out.print("Nr. of copies: ");
            int copies=Integer.parseInt(sc.nextLine());
            
            bm.addNewBook(isbn,title,year,copies);
        } catch(NumberFormatException e) {
            System.out.println("Wrong number format :(");
        }
    }

    //Handles updating book copies
    //sc = scanner for user input
    //bm = instance for update operations
    private static void updateCopies(Scanner sc, BookManager bm) {
        try {
            System.out.println("\n=== UPDATE COPIES ===");
            System.out.print("ISBN: ");
            String isbn=sc.nextLine();
            
            System.out.print("New amount of copies: ");
            int copies=Integer.parseInt(sc.nextLine());
            
            bm.updateCopies(isbn,copies);
        } catch(NumberFormatException e) {
            System.out.println("Invalid number!");
        }
    }
    
}