// ########################################
// ########## SETUP

// Express
require("dotenv").config();
const express = require("express");
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));

//const PORT = 4747;
const PORT = process.env.WEB_PORT;

// Database
const db = require("./database/db-connector");

// Handlebars
const { engine } = require("express-handlebars"); // Import express-handlebars engine
app.engine(".hbs", engine({ extname: ".hbs" })); // Create instance of handlebars
app.set("view engine", ".hbs"); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get("/", async function (req, res) {
  try {
    res.render("home"); // Render the home.hbs file
  } catch (error) {
    console.error("Error rendering page:", error);
    // Send a generic error message to the browser
    res.status(500).send("An error occurred while rendering the page.");
  }
});

app.get("/authors", async function (req, res) {
  try {
    // Create and execute our queries
    // In query1, we simply gather and display all authors
    const query1 = `SELECT Authors.authorID AS id, Authors.fName, Authors.lName, \
        Authors.country, Authors.birthyear FROM Authors;`;
    const [people] = await db.query(query1);

    // Render the bsg-people.hbs file, and also send the renderer
    //  an object that contains our bsg_people and bsg_homeworld information
    res.render("authors", { people: people });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/books", async function (req, res) {
  try {
    // Create and execute our queries
    // In query1, we use a JOIN clause to display the names of the books and their authors
    const query1 = `SELECT Books.bookID AS id, Books.title, \
        CONCAT(Authors.fName, ' ', Authors.lName) AS authorName, Books.genre, Books.price, \
        Books.stockQuantity, Books.publishYear, Books.isbn \
        FROM Books \
        LEFT JOIN Authors ON Books.authorID = Authors.authorID
        ORDER BY Books.title;`;
    const [books] = await db.query(query1);

    // Render the bsg-people.hbs file, and also send the renderer
    //  an object that contains our bsg_people and bsg_homeworld information
    res.render("books", { books: books });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/customers", async function (req, res) {
  try {
    // Create and execute our queries
    // In query1, we use a JOIN clause to display the names of the homeworlds
    const query1 = `SELECT Customers.customerID AS id, Customers.fName, Customers.lName, \
        Customers.email, Customers.phoneNumber, Customers.city, Customers.state \
        FROM Customers;`;

    const [customers] = await db.query(query1);

    // Render the bsg-people.hbs file, and also send the renderer
    //  an object that contains our bsg_people and bsg_homeworld information
    res.render("customers", { customers: customers });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/order_items", async function (req, res) {
  try {
    // Create and execute our queries
    // In query1, we use a JOIN clause to display the names of the homeworlds
    const query1 = `SELECT Orders.orderID, \
        CONCAT(Customers.fName, ' ', Customers.lName) AS customerName, \
        Orders.orderDate, OrderItems.quantity, OrderItems.subtotal, \
        Books.title, CONCAT(Authors.fName, ' ', Authors.lName) AS authorName \
        FROM Orders \
        LEFT JOIN Customers ON Orders.customerID = Customers.customerID \
        INNER JOIN OrderItems ON Orders.orderID = OrderItems.orderID \
        INNER JOIN Books on OrderItems.bookID = Books.bookID \
        INNER JOIN Authors ON Books.authorID = Authors.authorID \
        ORDER BY Orders.orderDate DESC, Orders.orderID DESC;`;

    const [items] = await db.query(query1);

    // Render the bsg-people.hbs file, and also send the renderer
    //  an object that contains our bsg_people and bsg_homeworld information
    res.render("order_items", { items });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

app.get("/orders", async function (req, res) {
  try {
    // Create and execute our queries
    // In query1, we use a JOIN clause to display the names of the homeworlds
    const query1 = `SELECT Orders.orderID as id, \
        CONCAT(Customers.fName, ' ', Customers.lName) AS customerName, \
        Orders.orderDate, Orders.totalAmount, Orders.paymentStatus \
        FROM Orders \
        LEFT JOIN Customers ON Orders.customerID = Customers.customerID \
        ORDER BY Orders.orderDate DESC, Orders.orderID DESC;
        `;

    const [orders] = await db.query(query1);

    // Render the bsg-people.hbs file, and also send the renderer
    //  an object that contains our bsg_people and bsg_homeworld information
    res.render("orders", { orders: orders });
  } catch (error) {
    console.error("Error executing queries:", error);
    // Send a generic error message to the browser
    res
      .status(500)
      .send("An error occurred while executing the database queries.");
  }
});

// STORED PROCEDURE ROUTES

// Delete all order items
app.post("/api/delete-all-order-items", async function (req, res) {
  try {
    const query1 = "CALL sp_delete_orderItems();";
    await db.query(query1);
    res.redirect(303, "/order_items");
  } catch (err) {
    console.error("Error executing PL/SQL:", err);
    res.status(500).render("error", { message: "Deletion failed." });
  }
});

// Reset the database
app.post("/api/reset-database", async function (req, res) {
  try {
    const query1 = "CALL sp_reset_bookstore();";
    await db.query(query1);
    res.redirect(303, "/order_items");
  } catch (error) {
    console.error("Error executing PL/SQL:", error);
    // Send a generic error message to the browser
    res.status(500).send("An error occurred while executing the PL/SQL.");
  }
});

app.listen(PORT, function () {
  console.log(
    "Express started on http://localhost:" +
      PORT +
      "; press Ctrl-C to terminate."
  );
});
