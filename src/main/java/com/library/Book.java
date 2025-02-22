package com.library;

public class Book {     //represent a book entity
    
    public final String isbnCode;
    public final String bookTitle;
    public final int publishYear;
    public final int numCopies;

    public Book(String isbn, String title, int year, int copies) {
        this.isbnCode=isbn;
        this.bookTitle=title;
        this.publishYear=year;
        this.numCopies=copies;
    }

    //returns a formatted string representation of the book
    public String toString() {
        return "\nISBN: " + isbnCode + "\nTitle: " + bookTitle
              + "\nYear: " + publishYear + "\nCopies: " + numCopies+"\n";
    }
}