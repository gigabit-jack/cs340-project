-- Schema for Project Group 71
-- Daniel Aguilar and Josh Goben

-- Create author table
CREATE TABLE Authors (
    authorID int(11) NOT NULL AUTO_INCREMENT,
    fName VARCHAR(50) NOT NULL,
    lName VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    birthyear YEAR,
    PRIMARY KEY (authorID)
);


-- Create customer table
CREATE TABLE Customers (
    customerID int(11) NOT NULL AUTO_INCREMENT,
    fName VARCHAR(50) NOT NULL,
    lName VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(15),
    city VARCHAR(50),
    state VARCHAR(50),
    UNIQUE (email),
    PRIMARY KEY (customerID)
);


-- Create books table
CREATE TABLE Books (
    bookID int(11) NOT NULL AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    authorID int(11) NOT NULL,
    genre VARCHAR(50),
    price DECIMAL(6,2) NOT NULL,
    stockQuantity INT NOT NULL,
    publishYear YEAR,
    isbn VARCHAR(20) NOT NULL,    
    UNIQUE (isbn),
    PRIMARY KEY (bookID),
    FOREIGN KEY (authorID) REFERENCES Authors(authorID)
);


-- Create orders table
CREATE TABLE Orders (
    orderID INT(11) NOT NULL AUTO_INCREMENT,
    customerID INT(11) NOT NULL,
    orderDate DATE NOT NULL,
    totalAmount DECIMAL(8,2) NOT NULL,
    paymentStatus VARCHAR(20),
    PRIMARY KEY (orderID),
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
);


-- Create orderItems table
CREATE TABLE OrderItems (
    orderItemID INT(11) NOT NULL AUTO_INCREMENT,
    orderID INT(11) NOT NULL,
    bookID INT(11) NOT NULL,
    quantity INT(4) NOT NULL,
    subtotal DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (orderItemID, orderID, bookID),
    FOREIGN KEY (orderID) REFERENCES Orders(orderID),
    FOREIGN KEY (bookID) REFERENCES Books(bookID)
);




-- Populating Project Group 71 tables with initial data


-- INSERT to author table
INSERT INTO Authors (fName, lName, country, birthyear)
VALUES 
("Nora Keita (N.K.)", "Jemisin", "USA", '1972'),
("Brandon", "Sanderson", NULL, '1975'),
("J.R.R.", "Tolkein", "United Kingdom", NULL);


-- INSERT to customer table
INSERT INTO Customers (fName, lName, email, phoneNumber, city, state)
VALUES 
("Ford", "Prefect", "hoopy@frood.com", '555-555-1234', "Las Vegas", "Nevada"),
("Bob", "Ross", "happy@littletrees.com", NULL, "Orlando", "Florida" ),
("Bene", "Gesserit", "secret@sisterhood.org", NULL, NULL, NULL);

-- INSERT to books table
INSERT INTO Books (title, authorID, genre, price, stockQuantity, publishYear, isbn)
VALUES
(
    "Mistborn: The Final Empire", 
    (SELECT authorID FROM Authors WHERE fName = "Brandon" AND lName = "Sanderson"), 
    "Fantasy",
    26.99, 
    17, 
    '2006', 
    "0-7653-1178-X"
),
(
    "The Fifth Season", 
    (SELECT authorID FROM Authors WHERE fName = "Nora Keita (N.K.)" AND lName = "Jemisin"), 
    NULL, 
    35.00, 
    99, 
    '2015', 
    "978-0-356-50819-1"
),
(
    "White Sand I", 
    (SELECT authorID FROM Authors WHERE fName = "Brandon" AND lName = "Sanderson"), 
    "Graphic Novel", 
    53.00, 
    22, 
    NULL, 
    "978-1606908853"
),
(
    "The Hobbit", 
    (SELECT authorID FROM Authors WHERE fName = "J.R.R." AND lName = "Tolkein"),  
    NULL, 
    19.99, 
    97, 
    NULL, 
    "978-0547928227"
);


 -- INSERT to orders table
INSERT INTO Orders (customerID, orderDate, totalAmount, paymentStatus)
VALUES
((SELECT customerID FROM Customers WHERE fName = "Ford" AND lName = "Prefect"), '2023-01-02', 19.99, NULL),
((SELECT customerID FROM Customers WHERE fName = "Bob" AND lName = "Ross"), '2024-03-14', 79.99, "Paid"),
((SELECT customerID FROM Customers WHERE fName = "Bene" AND lName = "Gesserit"), '2025-08-08', 105.00, "Pending")
;


-- INSERT to orderItems table
INSERT INTO OrderItems (orderID, bookID, quantity, subtotal)
VALUES
(
    (SELECT orderID FROM Orders WHERE customerID = (SELECT customerID FROM Customers WHERE fName = "Ford" AND lName = "Prefect")),
    (SELECT bookID FROM Books WHERE isbn = "978-0547928227"),
    1,
    '19.99'
),
(
    (SELECT orderID FROM Orders WHERE customerID = (SELECT customerID FROM Customers WHERE fName = "Bob" AND lName = "Ross")),
    (SELECT bookID FROM Books WHERE isbn = "0-7653-1178-X"),
    '1', 
    '26.99'
),
(
    (SELECT orderID FROM Orders WHERE customerID = (SELECT customerID FROM Customers WHERE fName = "Bob" AND lName = "Ross")),
    (SELECT bookID FROM Books WHERE isbn = "978-1606908853"),
    '1', 
    '53.00'
),
(
    (SELECT orderID FROM Orders WHERE customerID = (SELECT customerID FROM Customers WHERE fName = "Bene" AND lName = "Gesserit")),
    (SELECT bookID FROM Books WHERE isbn = "978-0-356-50819-1"),
    '3', 
    '105.00'
);
