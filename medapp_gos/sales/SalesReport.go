package sales

import (
	"log"
	d "medapp_gos/database" // Importing the database package to handle database connections
	"net/http"              // Importing the net/http package for HTTP handling
)

// Purpose :

// The code in the sales package is responsible for handling HTTP GET requests to retrieve sales data from the database based on a specified date range. It connects to the database, performs a query to fetch sales records, and sends the results back to the client in JSON format.
// Request and Response
// Request:

//     Method: GET
//     Endpoint: (Assumed endpoint would be something like /sales)
//     Query Parameters:
//         from_date: The start date for filtering sales records.
//         to_date: The end date for filtering sales records.

// Response:

//     Type: JSON
//     Structure:
//         Status: Indicates the result of the request.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains an optional error message if an error occurs, including a custom error code and description.
//         SalesResultArr: An array of SalesResult objects, where each object contains:
//             Bill_No (string): Bill number.
//             Medicine_Name (string): Name of the medicine.
//             Bill_Date (string): Date of the bill.
//             Quantity (int): Quantity of medicine sold.
//             NetPrice (float64): Net price of the medicine.

// SalesResult represents the structure of a single sales record
type SalesResult struct {
	BillNo        string  `json:"Bill_No" gorm:"column:Bill_No"`
	Medicine_Name string  `json:"Medicine_Name" gorm:"column:medicine_name"`
	Bill_Date     string  `json:"Bill_Date" gorm:"column:bill_date;type:date"`
	Quantity      int     `json:"Quantity" gorm:"column:quantity"`
	Netprice      float64 `json:"netprice" gorm:"column:netprice"`
}

// SalesResponse represents the structure of the response containing sales data
type SalesResponse struct {
	Status         string        `json:"status"`           // Status of the response (e.g., "S" for success, "E" for error)
	ErrMsg         string        `json:"errMsg,omitempty"` // Optional error message
	SalesResultArr []SalesResult `json:"salesResultArr"`   // Array of sales records
}

// Sales handles GET requests to return sales data based on date range.
func Sales(pw http.ResponseWriter, pr *http.Request) {
	// Set headers for CORS and content-type
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")                                                                   // Allow GET and OPTIONS methods
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow these headers

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		pw.WriteHeader(http.StatusOK) // Respond with 200 OK for OPTIONS requests
		return
	}

	// Handle GET request
	if pr.Method == "GET" {
		var lresp SalesResponse // Initialize the response structure
		lresp.Status = "S"      // Set the initial status to success

		// Connect to the database
		db, lerr := d.LocalDBConnect() // Attempt to connect to the local database
		DB, _ := db.DB()
		if lerr != nil {
			log.Println("Error reading body:", lerr)      // Log the error if database connection fails
			lresp.Status = "E"                            // Set status to error
			lresp.ErrMsg = "Error : SS01 " + lerr.Error() // Set error message
			respondWithJSON(pw, lresp)                    // Send the response
			return
		}
		defer DB.Close()
		startDate := pr.URL.Query().Get("from_date") // Get the "from_date" parameter from the URL query string
		endDate := pr.URL.Query().Get("to_date")     // Get the "to_date" parameter from the URL query string

		var results []SalesResult
		res := db.Table("st860_bill_master sd").
			Select("sd.Bill_No, ss.medicine_name, sd.bill_date, ss.quantity, ss.netprice").
			Joins("LEFT JOIN st860_bill_master_details ss ON sd.bill_No = ss.Bill_No").
			Where("sd.bill_date >= ? AND sd.bill_date <= ?", startDate, endDate).
			Group("sd.Bill_No, ss.medicine_name, sd.bill_date, ss.quantity, ss.netprice").
			Find(&results)

		if res.Error != nil {
			log.Println("Error reading body:", lerr)           // Log the error if the query fails
			lresp.Status = "E"                                 // Set status to error
			lresp.ErrMsg = "Error : SS02 " + res.Error.Error() // Set error message
			respondWithJSON(pw, lresp)                         // Send the response
			return
		}
		lresp.SalesResultArr = results
		// Send successful response
		respondWithJSON(pw, lresp) // Send the response containing the sales data
		log.Println("Sales(-)")    // Log successful completion
	} else {
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with 405 Method Not Allowed for non-GET requests
	}
}
