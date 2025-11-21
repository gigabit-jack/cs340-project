-- Group 71 Step 4 DML SQL
-- Online Bookstore Management System
-- Daniel Aguilar and Josh Goben
-- Queries used by the web application UI (Authors, Books, Customers,
-- Orders/OrderItems, and dashboard reports).

/* ----------------------------------------------------------------------
AUTHORS PAGE QUERIES
---------------------------------------------------------------------- */

-- A1: Browse all authors
SELECT
    authorID,
    fName,
    lName,
    country,
    birthyear
FROM Authors
ORDER BY lName, fName;

-- A2: Insert a new author (values will be supplied by the web form)
-- @fNameInput, @lNameInput, @countryInput, @birthYearInput are variables
INSERT INTO
    Authors (
        fName,
        lName,
        country,
        birthyear
    )
VALUES (
        @fNameInput,
        @lNameInput,
        @countryInput,
        @birthYearInput
    );

-- A3: Update an existing author
-- @authorIDInput identifies which author to update
UPDATE Authors
SET
    fName = @fNameInput,
    lName = @lNameInput,
    country = @countryInput,
    birthyear = @birthYearInput
WHERE
    authorID = @authorIDInput;

-- A4: Delete an author by ID
-- In later steps we may add ON DELETE actions or checks before this runs
DELETE FROM Authors WHERE authorID = @authorIDInput;

/* ----------------------------------------------------------------------
BOOKS PAGE QUERIES
---------------------------------------------------------------------- */

-- B1: Browse all books with author names
SELECT B.bookID, B.title, CONCAT(A.fName, ' ', A.lName) AS authorName, B.genre, B.price, B.stockQuantity, B.publishYear, B.isbn
FROM Books AS B
    JOIN Authors AS A ON B.authorID = A.authorID
ORDER BY B.title;

-- B2: Insert a new book
-- @authorIDDropdown will come from a dropdown listing Authors
INSERT INTO
    Books (
        title,
        authorID,
        genre,
        price,
        stockQuantity,
        publishYear,
        isbn
    )
VALUES (
        @titleInput,
        @authorIDDropdown,
        @genreInput,
        @priceInput,
        @stockQuantityInput,
        @publishYearInput,
        @isbnInput
    );

-- B3: Update a book's price and stock quantity
UPDATE Books
SET
    price = @priceInput,
    stockQuantity = @stockQuantityInput
WHERE
    bookID = @bookIDInput;

-- B4: Delete a book by ID
-- In a later step we may add logic so that Orders / OrderItems stay consistent
DELETE FROM Books WHERE bookID = @bookIDInput;

/* ----------------------------------------------------------------------
CUSTOMERS PAGE QUERIES
---------------------------------------------------------------------- */

-- C1: Browse all customers
SELECT
    customerID,
    fName,
    lName,
    email,
    phoneNumber,
    city,
    state
FROM Customers
ORDER BY lName, fName;

-- C2: Search customers by last name or email
-- Either last-name search or email search can be used
SELECT
    customerID,
    fName,
    lName,
    email,
    phoneNumber,
    city,
    state
FROM Customers
WHERE
    lName LIKE CONCAT('%', @lastNameSearch, '%')
    OR email = @emailSearch
ORDER BY lName, fName;

-- C3: Insert a new customer
INSERT INTO
    Customers (
        fName,
        lName,
        email,
        phoneNumber,
        city,
        state
    )
VALUES (
        @fNameInput,
        @lNameInput,
        @emailInput,
        @phoneNumberInput,
        @cityInput,
        @stateInput
    );

-- C4: Update an existing customer
UPDATE Customers
SET
    fName = @fNameInput,
    lName = @lNameInput,
    email = @emailInput,
    phoneNumber = @phoneNumberInput,
    city = @cityInput,
    state = @stateInput
WHERE
    customerID = @customerIDInput;

-- C5: Delete a customer
DELETE FROM Customers WHERE customerID = @customerIDInput;

/* ----------------------------------------------------------------------
ORDERS AND ORDER ITEMS PAGE QUERIES
---------------------------------------------------------------------- */

-- O1: Browse all orders with customer name
SELECT O.orderID, O.orderDate, O.totalAmount, O.paymentStatus, C.customerID, CONCAT(C.fName, ' ', C.lName) AS customerName
FROM Orders AS O
    JOIN Customers AS C ON O.customerID = C.customerID
ORDER BY O.orderDate DESC, O.orderID DESC;

-- O2: View a single order and its line items
SELECT O.orderID, O.orderDate, O.paymentStatus, C.customerID, CONCAT(C.fName, ' ', C.lName) AS customerName, B.bookID, B.title, OI.quantity, OI.subtotal
FROM
    Orders AS O
    JOIN Customers AS C ON O.customerID = C.customerID
    JOIN OrderItems AS OI ON O.orderID = OI.orderID
    JOIN Books AS B ON OI.bookID = B.bookID
WHERE
    O.orderID = @orderIDInput
ORDER BY B.title;

-- O3: Insert a new order header
-- The backend will compute @totalAmountInput and pass it here
INSERT INTO
    Orders (
        customerID,
        orderDate,
        totalAmount,
        paymentStatus
    )
VALUES (
        @customerIDDropdown,
        @orderDateInput,
        @totalAmountInput,
        @paymentStatusInput
    );

-- O4: Insert a new order line (M:N insert between Orders and Books)
INSERT INTO
    OrderItems (
        orderID,
        bookID,
        quantity,
        subtotal
    )
VALUES (
        @orderIDInput,
        @bookIDDropdown,
        @quantityInput,
        @subtotalInput
    );

-- O5: Update an order's payment status
UPDATE Orders
SET
    paymentStatus = @paymentStatusInput
WHERE
    orderID = @orderIDInput;

-- O6: Update an order item's quantity and subtotal
UPDATE OrderItems
SET
    quantity = @quantityInput,
    subtotal = @subtotalInput
WHERE
    orderItemID = @orderItemIDInput;

-- O7: Delete a single order item
DELETE FROM OrderItems WHERE orderItemID = @orderItemIDInput;

-- O8: Delete an order and all of its line items
-- This two-step pattern avoids orphaned OrderItems rows when foreign
-- keys do not use ON DELETE CASCADE.
DELETE FROM OrderItems WHERE orderID = @orderIDInput;

DELETE FROM Orders WHERE orderID = @orderIDInput;

/* ----------------------------------------------------------------------
REPORTING / DASHBOARD QUERIES
---------------------------------------------------------------------- */

-- R1: Find books that are low in stock (for example, fewer than 10 copies)
SELECT B.bookID, B.title, B.stockQuantity
FROM Books AS B
WHERE
    B.stockQuantity < 10
ORDER BY B.stockQuantity ASC, B.title;

-- R2: Top-selling books by total quantity ordered
SELECT B.bookID, B.title, SUM(OI.quantity) AS totalQuantitySold
FROM Books AS B
    JOIN OrderItems AS OI ON B.bookID = OI.bookID
GROUP BY
    B.bookID,
    B.title
ORDER BY totalQuantitySold DESC, B.title;
