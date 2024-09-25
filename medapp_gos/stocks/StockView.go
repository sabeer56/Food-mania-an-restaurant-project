package stocks

import (
	"log"                   // Importing log package for logging errors
	d "medapp_gos/database" // Importing a custom database package for database operations
	"net/http"              // Importing net/http package for HTTP request handling
)

// Purpose :

// The stocks package contains the StockViews function, which is responsible for handling HTTP GET requests to retrieve stock data from a database. This function connects to the database, executes a query to fetch stock information, processes the results, and returns the data in a JSON format. It also handles errors that may occur during the database operations and request processing.
// Request and Response
// Request:

//     Method: GET
//     Endpoint: (Assumed endpoint would be something like /stocks/view)
//     Headers:
//         Accept: Specifies the media type(s) that the client is willing to receive.
//         Content-Type: (Optional) Specifies the media type of the resource being sent to the server.
//         X-CSRF-Token: (Optional) Used for Cross-Site Request Forgery protection.
//         Authorization: (Optional) Contains credentials for authenticating the client with the server.

// Response:

//     Type: JSON
//     Structure:
//         Status: Indicates the result of the request.
//             "S" for success.
//             "E" for error.
//         ErrMessage: Contains an optional error message if an error occurs, including a custom error code and description.
//         StockArr: Array of Stock records containing:
//             medicine_name (string): Name of the medicine.
//             quantity (int): Quantity of the medicine in stock.
//             unit_price (int): Unit price of the medicine.
//             brand (string): Brand of the medicine.

// StockViews handles the HTTP request to view stock data.
func StockViews(pw http.ResponseWriter, pr *http.Request) {
	// Set headers for CORS (Cross-Origin Resource Sharing) to allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Origin", "*")
	pw.Header().Set("Access-Control-Allow-Credentials", "true")
	pw.Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")
	pw.Header().Set("Content-Type", "application/json")
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		// If the request method is OPTIONS, respond with 200 OK and return
		pw.WriteHeader(http.StatusOK)
		return
	}

	// Handle GET request to fetch stock data
	if pr.Method == "GET" {
		var resp StockResponse
		resp.Status = "S" // Initialize response status to "S" (success)

		// Connect to the database
		db, err := d.LocalDBConnect()
		DB, _ := db.DB()
		if err != nil {
			// Log and handle database connection errors
			log.Println("Database connection error:", err)
			resp.ErrMessage = "Error : SSV01 " + err.Error() // Set error message with code SSV01
			resp.Status = "E"                                // Set response status to "E" (error)
			sendResponse(pw, resp)                           // Send error response
			return
		}
		defer DB.Close()
		var results []Result
		res := db.Table("st860_medicine_stock as sd").
			Select("sd.medicine_name, sd.quantity, sd.unit_price, sm.brand").
			Joins("INNER JOIN st860_medicine_master sm ON sd.m_id = sm.id").
			Scan(&results)

		if res.Error != nil {
			resp.ErrMessage = "Error : SSV02 " + res.Error.Error() // Set error message with code SSV01
			resp.Status = "E"                                      // Set response status to "E" (error)
			sendResponse(pw, resp)                                 // Send error response
		}
		resp.StockArr = results
		sendResponse(pw, resp)
	} else {
		// Handle methods other than GET
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with 405 Method Not Allowed
	}
}
