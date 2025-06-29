/*
 * This file is part of the Municipal Library Management System.
 * Copyright (c) 2025 Emanuele Pippa
 * Licensed under the MIT License. See the LICENSE file for details.
 */

package com.library;

import java.sql.Date;

//Loan (book borrowing operation) in the library system. 
//Manages the borrowing and the return of a book, including librarian authorization.
public class Loan {
    private Date startDate;
    private String bookISBN;
    private int clientId;
    private Date endDate;
    private Date returnDate;
    private String returnNotes;
    private String loanStatus;

    public Loan(Date startDate, String bookISBN, int clientId, Date endDate, String loanStatus) {
        this.startDate = startDate;
        this.bookISBN = bookISBN;
        this.clientId = clientId;
        this.endDate = endDate;
        this.loanStatus = loanStatus;
    }

    public Date getStartDate() { return startDate; }
    public String getBookISBN() { return bookISBN; }
    public int getClientId() { return clientId; }
    public Date getEndDate() { return endDate; }
    public Date getReturnDate() { return returnDate; }
    public String getReturnNotes() { return returnNotes; }
    public String getLoanStatus() { return loanStatus; }

    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }
    public void setReturnNotes(String notes) { this.returnNotes = notes; }
}
