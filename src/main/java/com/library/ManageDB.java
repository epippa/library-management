package com.library;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.Scanner;

public class ManageDB { //DB initialization and resource cleanup
    
    //initialize database schema using sql script
    public static void initDB(Connection conn) {    //conn = activate db connection
        try(InputStream input=ManageDB.class.getResourceAsStream("/epippa_database_library.sql");
             Scanner sc=new Scanner(input,StandardCharsets.UTF_8.name());
             Statement stmt=conn.createStatement()) {
            
            String sql=sc.useDelimiter("\\A").next();
            stmt.execute(sql);
            System.out.println("DB initialized!");
            
        } catch(Exception e) {
            System.err.println("DB initialization error");
        }
    }
    
    //safely closes the database connection and scanner
    //c = close connection
    //s = close scanner
    public static void closeStuff(Connection c,Scanner s) {
        try {
            if(c!=null && !c.isClosed()) {
                c.close();
            }
        } catch(SQLException e) {
            System.err.println("Closing error");
        }
        
        if(s!=null) {
            s.close();
        }
    }
}