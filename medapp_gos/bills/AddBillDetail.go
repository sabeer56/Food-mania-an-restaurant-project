package bills

import (
	"encoding/json"         // Importing the JSON package for encoding and decoding JSON data
	"io"                    // Importing the io package for reading the request body
	"log"                   // Importing the log package for logging errors and information
	d "medapp_gos/database" // Importing a custom database package for database operations
	"net/http"              // Importing the http package for HTTP handling
	"time"                  // Importing the time package for formatting dates
)

// The AddBillDetails function is designed to handle HTTP requests that add detailed bill information to a database. This function is responsible for processing incoming POST requests that contain bill data in JSON format, validating and inserting that data into the database, and returning an appropriate response. The function also handles CORS preflight requests and ensures proper response formatting for various scenarios such as errors and successful data insertion.
// Request and Response
// Request:

//     Method: POST (for adding bill details) and OPTIONS (for handling CORS preflight).
//     Content-Type: application/json
//     Body: A JSON array of bill records, where each bill record contains details such as Bill_No, Medicine_Name, Quantity, Bill_Amount, Total, Created_By, etc.

// Response:

//     Content-Type: application/json

//     Status Code:
//         200 OK for successful POST requests.
//         405 Method Not Allowed for unsupported HTTP methods.
// Body :
//  Success Response :
// {
//   "Status": "S",
//   "ErrMsg": ""
// }
//  Error Response :
// {
// 	"Status": "E",
// 	"ErrMsg": "Error : <error_code> <error_description>"
//   }

// AddBillDetails handles HTTP requests to add detailed bill information.
func AddBillDetails(pw http.ResponseWriter, pr *http.Request) {
	// Set headers to handle CORS and specify the content type
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")                                                                  // Allow POST and OPTIONS HTTP methods
	pw.Header().Set("Content-Type", "application/json")                                                                              // Set content type to JSON
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers in requests

	// Handle preflight OPTIONS request (for CORS)
	if pr.Method == "OPTIONS" {
		pw.WriteHeader(http.StatusOK) // Respond with 200 OK for OPTIONS request
		return                        // End function execution
	}

	// Handle POST request for adding bill details
	if pr.Method == "POST" {
		var billRecs []Bill_master_details // Variable to hold the slice of bills from the request
		var lresp GBillResponse            // Variable to hold the response details

		// Read the body of the request
		body, lerr := io.ReadAll(pr.Body)
		if lerr != nil {
			// If reading the body fails, set the response to error and return
			lresp.Status = "E"
			lresp.ErrMsg = "Error : BABD01 " + lerr.Error() // Set specific error code and message
			sendResponse(pw, lresp)                         // Send error response
			return                                          // End function execution
		}

		// Unmarshal the JSON body into a slice of GBill
		lerr = json.Unmarshal(body, &billRecs)
		if lerr != nil {
			// If unmarshalling fails, set the response to error and return
			lresp.Status = "E"
			lresp.ErrMsg = "Error : BABD02 " + lerr.Error() // Set specific error code and message
			sendResponse(pw, lresp)                         // Send error response
			return                                          // End function execution
		}

		// Connect to the database
		db, lerr := d.LocalDBConnect()
		DB, _ := db.DB()
		if lerr != nil {
			// If database connection fails, set the response to error and return
			lresp.Status = "E"
			lresp.ErrMsg = "Error : BABD03 " + lerr.Error() // Set specific error code and message
			sendResponse(pw, lresp)                         // Send error response
			return                                          // End function execution
		}
		defer DB.Close()
		// Process each bill record
		for _, billRec := range billRecs {
			// Prepare the SQL statement for inserting bill details into the database
			gst := float64(billRec.UnitPrice) * 0.18
			total := float64(gst) + float64(billRec.UnitPrice)
			billMasterDetails := Bill_master_details1{
				Bill_No:       billRec.Bill_No,
				Medicine_Name: billRec.Medicine_Name,
				Quantity:      billRec.Quantity,
				UnitPrice:     billRec.UnitPrice,
				Netprice:      total,
				Created_By:    billRec.Created_By,
				Created_Date:  time.Now(),
			}
			res := db.Table("St860_bill_master_details").Create(&billMasterDetails)
			if res.Error != nil {
				// If inserting the bill detail fails, set the response to error and return
				lresp.Status = "E"
				lresp.ErrMsg = "Error : BABD04 " + res.Error.Error() // Set specific error code and message
				sendResponse(pw, lresp)                              // Send error response
				return                                               // End function execution
			}
		}

		// If all operations succeed, set the response to success
		lresp.Status = "S"
		lresp.ErrMsg = ""            // Clear error message for successful response
		sendResponse(pw, lresp)      // Send success response
		log.Println("InsertData(-)") // Log successful data insertion

	} else {
		// If the request method is not POST, send a 405 Method Not Allowed response
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed)
	}
}
