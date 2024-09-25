package main

import (
	"fmt"                      // For formatting and printing messages
	a "medapp_gos/adduser"     // Importing the adduser package with an alias 'a'
	b "medapp_gos/bills"       // Importing the bills package with an alias 'b'
	i "medapp_gos/inventry"    // Importing the inventory package with an alias 'i'
	lh "medapp_gos/logHistory" // Importing the logHistory package with an alias 'lh'
	l "medapp_gos/login"       // Importing the login package with an alias 'l'
	sl "medapp_gos/sales"      // Importing the sales package with an alias 'sl'
	s "medapp_gos/stocks"      // Importing the stocks package with an alias 's'
	t "medapp_gos/todaysales"  // Importing the todaysales package with an alias 't'
	"net/http"                 // For handling HTTP requests and responses
)

/*
Package `main` sets up and configures an HTTP server to handle various routes related to a medical application.

### Purpose

The primary purpose of the `main` package is to:
1. Define HTTP route handlers for different API endpoints.
2. Map each route to a corresponding function from various packages that handle specific operations related to user management, log history, stock management, billing, sales reporting, and inventory.
3. Start an HTTP server that listens for incoming requests on port 9090.

### HTTP Route Handlers

The `main` function sets up HTTP route handlers using the `http.HandleFunc` function, mapping specific URL paths to handler functions from different packages. Each handler function processes requests and generates responses according to its functionality.

1. **User Management:**
   - `/adduser`: Handled by `a.Adduser` function from the `adduser` package. Responsible for adding new users.
   - `/getuser`: Handled by `l.Getuser` function from the `login` package. Retrieves user information.

2. **Log History:**
   - `/addloghistory`: Handled by `lh.AddLogs` function from the `logHistory` package. Adds new log history entries.
   - `/getuserlogs`: Handled by `lh.GetuserLogs` function from the `logHistory` package. Retrieves user log history.
   - `/updateloghistory`: Handled by `lh.UpdateLogHistory` function from the `logHistory` package. Updates existing log history.

3. **Stock Management:**
   - `/addstock`: Handled by `s.AddStocks` function from the `stocks` package. Adds new stock information.
   - `/updatestock`: Handled by `s.UpdateStocks` function from the `stocks` package. Updates existing stock information.
   - `/stockviewnames`: Handled by `s.StockViewName` function from the `stocks` package. Retrieves stock names.
   - `/stockview`: Handled by `s.StockViews` function from the `stocks` package. Retrieves detailed information about stocks.

4. **Billing:**
   - `/addbill`: Handled by `b.AddBills` function from the `bills` package. Adds new billing records.
   - `/addbilldetails`: Handled by `b.AddBillDetails` function from the `bills` package. Adds details to billing records.

5. **Sales Reporting:**
   - `/salesreport`: Handled by `sl.Sales` function from the `sales` package. Generates sales reports.

6. **Today's Sales:**
   - `/todaysales`: Handled by `t.TodaySales` function from the `todaysales` package. Retrieves sales data for the current day.

7. **Inventory:**
   - `/currentInventry`: Handled by `i.CurrentInventryval` function from the `inventry` package. Retrieves current inventory values.

### Request and Response Handling

- **Requests:**
  Each route is associated with a specific handler function that processes incoming HTTP requests. The handler functions are responsible for:
  - Parsing request parameters or body content.
  - Performing necessary operations (e.g., database queries, data processing).
  - Generating appropriate responses based on the request and operation results.

- **Responses:**
  Each handler function generates responses in various formats, typically JSON, to communicate the results of the request. The responses include:
  - Status codes indicating success or failure of the operation.
  - Relevant data or error messages.

### Response Commands

- **`fmt.Println(http.ListenAndServe(":9090", nil))`:**
  - Starts the HTTP server on port `9090` and listens for incoming requests.
  - If the server encounters any errors while starting or running, they are printed to the console.

This setup ensures that the application can handle a range of API endpoints related to user management, log history, stock management, billing, sales, and inventory, providing a centralized entry point for the entire system.
*/

func main() {
	// Set up HTTP route handlers to handle specific paths
	http.HandleFunc("/adduser", a.Adduser)                    // Route for adding a user, handled by Adduser function in the adduser package
	http.HandleFunc("/getuser", l.LoginApi)                   // Route for retrieving user information, handled by Getuser function in the login package
	http.HandleFunc("/addloghistory", lh.AddLogs)             // Route for adding log history entries, handled by AddLogs function in the logHistory package
	http.HandleFunc("/getuserlogs", lh.GetuserLogs)           // Route for retrieving user log history, handled by GetuserLogs function in the logHistory package
	http.HandleFunc("/updateloghistory", lh.UpdateLogHistory) // Route for updating log history, handled by UpdateLogHistory function in the logHistory package
	http.HandleFunc("/addstock", s.AddStocks)                 // Route for adding stock, handled by AddStocks function in the stocks package
	http.HandleFunc("/updatestock", s.UpdateStocks)           // Route for updating stock information, handled by UpdateStocks function in the stocks package
	http.HandleFunc("/stockview", s.StockViews)               // Route for viewing stock details, handled by StockViews function in the stocks package
	http.HandleFunc("/addbill", b.AddBills)                   // Route for adding bills, handled by AddBills function in the bills package
	http.HandleFunc("/addbilldetails", b.AddBillDetails)      // Route for adding bill details, handled by AddBillDetails function in the bills package
	http.HandleFunc("/salesreport", sl.Sales)                 // Route for generating sales reports, handled by Sales function in the sales package
	http.HandleFunc("/todaysales", t.TotalSales)              // Route for retrieving today's sales, handled by TodaySales function in the todaysales package
	http.HandleFunc("/currentInventry", i.CurrentInventryval) // Route for getting current inventory values, handled by CurrentInventryval function in the inventory package
	http.HandleFunc("/monthlyapi", b.MonthlyApi)
	// Start the HTTP server on port 9090 and log any errors
	fmt.Println(http.ListenAndServe(":9090", nil)) // Starts the HTTP server on port 9090, and prints any errors to the console
}
