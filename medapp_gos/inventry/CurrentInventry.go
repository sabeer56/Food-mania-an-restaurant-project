package inventry

import (
	"fmt"
	"log"                   // Import the log package for logging messages
	d "medapp_gos/database" // Import the database package for database connection functions
	"net/http"              // Import the HTTP package for handling HTTP requests and responses
)

// Purpose :

// The CurrentInventryval function handles HTTP GET requests to retrieve and return the total inventory value from the database. It calculates the total value by summing up the product of quantity and unit price from the st860_medicine_stock table. The function handles CORS preflight requests, manages database connections, processes SQL queries, and returns a JSON response with the inventory value or an error message if something goes wrong.
// Request and Response
// Request:

//     Method: GET (for retrieving inventory data) and OPTIONS (for handling CORS preflight requests).
//     Content-Type: The function responds with application/json, but the request itself does not require a specific content type.

// Response:

//     Content-Type: application/json

//     Status Code:
//         200 OK for successful GET requests.
//         405 Method Not Allowed for unsupported HTTP methods.

//     Body:

//         Success Response:
// {
// 	"status": "S",
// 	"errMsg": "",
// 	"inventryval": <total_inventory_value>
//   }
//        Error Response:
// {
// 	"status": "E",
// 	"errMsg": "Error : <error_code> <error_description>"
//   }

// CurrentInventryResponse represents the response structure
type CurrentInventryResponse struct {
	Status      string `json:"status"`                         // Status of the response (e.g., "S" for success, "E" for error)
	ErrMsg      string `json:"errMsg,omitempty"`               // Optional error message (present only in case of an error)
	InventryVal int    `json:"inventryval" gorm:"inventryval"` // Inventory value calculated from the database
}

// CurrentInventryval handles GET requests to return inventory data
func CurrentInventryval(pw http.ResponseWriter, pr *http.Request) {
	// Set headers for CORS (Cross-Origin Resource Sharing) and content-type
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")                                                                   // Allow GET and OPTIONS HTTP methods
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers in requests

	// Handle preflight OPTIONS request (used for CORS checks)
	if pr.Method == "OPTIONS" {
		pw.WriteHeader(http.StatusOK) // Respond with a 200 OK status for OPTIONS requests
		return                        // End the function execution
	}

	// Handle GET request (the main functionality of this handler)
	if pr.Method == "GET" {
		var lresp CurrentInventryResponse // Declare a variable to hold the response data
		lresp.Status = "S"                // Set the initial status to "S" (success)

		// Connect to the database
		db, lerr := d.LocalDBConnect() // Call the LocalDBConnect function from the database package
		DB, _ := db.DB()
		if lerr != nil {
			// If connection fails, set the response status to "E" (error) and include the error message
			lresp.Status = "E"
			lresp.ErrMsg = "Error : ICI01 " + lerr.Error()
			sendJSONResponse(pw, lresp) // Send the error response
			return                      // End the function execution
		}
		defer DB.Close()
		res := db.Table("st860_medicine_stock").Select("sum(quantity * unit_price)").Scan(&lresp.InventryVal)
		fmt.Println(200, lresp.InventryVal)
		if res.Error != nil {
			// If there is an error retrieving the result, set the response status to "E" and include the error message
			lresp.Status = "E"
			lresp.ErrMsg = "Error : ICI02 " + res.Error.Error()
			sendJSONResponse(pw, lresp) // Send the error response
			return                      // End the function execution
		}

		// Send the successful response
		sendJSONResponse(pw, lresp)                          // Send the response with the inventory value
		log.Println("Inventory data retrieved successfully") // Log a message indicating success
	} else {
		// Handle unsupported HTTP methods
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with a 405 Method Not Allowed status
	}
}
