/*
 * This file is part of the Municipal Library Management System.
 * Copyright (c) 2025 Emanuele Pippa
 * Licensed under the MIT License. See the LICENSE file for details.
 */

package com.library;

public class Book {  //Represents a book entity

    public final String isbnCode;
    public final String bookTitle;
    public final int publishYear;
    public final int numCopies;
    public final int availableCopies;
    public final int edition;

    public Book(String isbn, String title, int year, int copies, int availableCopies, int edition) {
        this.isbnCode = isbn;
        this.bookTitle = title;
        this.publishYear = year;
        this.numCopies = copies;
        this.availableCopies = availableCopies;
        this.edition = edition;
    }

    public String toString() {
        return "\nISBN: " + isbnCode + "\nTitle: " + bookTitle
              + "\nYear: " + publishYear + "\nEdition: " + edition
              + "\nCopies: " + numCopies + "\nAvailable: " + availableCopies + "\n";
    }
}
