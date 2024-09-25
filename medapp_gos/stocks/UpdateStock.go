package stocks

import (
	"encoding/json"         // For encoding and decoding JSON data
	"fmt"                   // For formatting strings
	"io/ioutil"             // For reading the request body
	"log"                   // For logging errors and informational messages
	d "medapp_gos/database" // Custom package for database operations
	"net/http"              // For handling HTTP requests and responses
	"time"                  // For handling date and time
)

/*
Package `stocks` provides functionality for handling HTTP requests related to stock updates in a medical application.

The `UpdateStocks` function is designed to manage HTTP requests for updating stock information. Specifically, it allows clients to submit POST requests with stock data, which the server then processes and updates in the database.

### Purpose

The primary purpose of the `UpdateStocks` function is to:
1. Handle HTTP requests for updating stock information in the `st860_medicine_stock` table of the database.
2. Ensure proper handling of CORS (Cross-Origin Resource Sharing) to allow requests from different origins.
3. Validate and process the incoming request data, handle errors, and provide appropriate responses.

### Request Handling

1. **CORS Configuration:** The function sets various headers to manage CORS, including:
   - `Access-Control-Allow-Origin`: Allows requests from any origin (`*`).
   - `Access-Control-Allow-Credentials`: Permits credentials to be included in requests.
   - `Access-Control-Allow-Methods`: Specifies allowed HTTP methods (`POST, OPTIONS`).
   - `Content-Type`: Indicates that the response content type is JSON.
   - `Access-Control-Allow-Headers`: Lists allowed request headers.

2. **Preflight Request Handling:** If the request method is `OPTIONS`, it responds with a `200 OK` status, as part of the CORS preflight request handling.

3. **POST Request Processing:**
   - **Read and Parse Request Body:** Reads the request body and parses it from JSON format into a `Stock` struct.
   - **Database Connection:** Connects to the local database using `d.LocalDBConnect()`.
   - **Retrieve Existing Data:** Executes a query to retrieve the creator and creation date of the specified medicine.
   - **Insert Updated Stock Data:** Inserts the updated stock information into the `st860_medicine_stock` table.
   - **Error Handling:** Handles various potential errors, including issues with reading the request body, parsing JSON, database connectivity, and SQL execution.

### Response Handling

1. **Error Responses:** If any error occurs during request processing, the function:
   - Logs the error.
   - Sets the response status to `"E"` (error).
   - Includes an error message detailing the issue.
   - Sends the error response using `sendResponse(pw, resp)`.

2. **Success Responses:** If the stock update is successful:
   - Sets the response status to `"S"` (success).
   - Logs a success message.
   - Sends the successful response using `sendResponse(pw, resp)`.

3. **Method Not Allowed:** If the request method is not `POST`, it responds with a `405 Method Not Allowed` status.

### Response Commands

- `sendResponse(pw, resp)`:
  - A utility function used to send the JSON-encoded response back to the client. This function is assumed to handle encoding the `resp` object to JSON format and writing it to the `pw` (response writer).

The `UpdateStocks` function integrates various aspects of error handling, response generation, and database interaction to provide a robust mechanism for updating stock information in the application.
*/

// UpdateStocks handles the HTTP request to update stock information.
func UpdateStocks(pw http.ResponseWriter, pr *http.Request) {
	// Set headers for CORS (Cross-Origin Resource Sharing) and content type
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Credentials", "true")                                                                      // Allow credentials to be included in requests
	pw.Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")                                                                  // Allow POST and OPTIONS methods
	pw.Header().Set("Content-Type", "application/json")                                                                              // Set content type to JSON
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		// Respond with 200 OK and return if the request method is OPTIONS
		pw.WriteHeader(http.StatusOK)
		return
	}

	// Handle POST request to update stock information
	if pr.Method == "POST" {
		var stockRec St860_medicine_stock1 // Initialize a variable to hold the stock data from the request
		var resp StockResponse             // Initialize a response variable

		// Read the entire request body
		body, err := ioutil.ReadAll(pr.Body)
		if err != nil {
			// Log and handle errors reading the body
			log.Println("Error reading body:", err)
			resp.Status = "E"                                            // Set response status to "E" (error)
			resp.ErrMessage = fmt.Sprintf("Error reading body: %v", err) // Set error message
			sendResponse(pw, resp)                                       // Send the error response
			return
		}

		// Parse the JSON request body into the stockRec variable
		err = json.Unmarshal(body, &stockRec)
		if err != nil {
			// Log and handle errors unmarshalling JSON
			log.Println("Error unmarshalling JSON:", err)
			resp.Status = "E"                                                  // Set response status to "E" (error)
			resp.ErrMessage = fmt.Sprintf("Error unmarshalling JSON: %v", err) // Set error message
			sendResponse(pw, resp)                                             // Send the error response
			return
		}

		// Connect to the database
		db, err := d.LocalDBConnect()
		DB, _ := db.DB()
		if err != nil {
			// Log and handle database connection errors
			log.Println("Database connection error:", err)
			resp.Status = "E"                                                   // Set response status to "E" (error)
			resp.ErrMessage = fmt.Sprintf("Database connection error: %v", err) // Set error message
			sendResponse(pw, resp)                                              // Send the error response
			return
		}
		defer DB.Close()
		// Retrieve the creator and creation date of the medicine to update
		// var result struct {
		// 	lUser string    // Variable to hold the creator's username
		// 	ldate time.Time // Variable to hold the creation date
		// }

		// db.Select("created_by, created_date").Where("medicine_name=?", stockRec.Medicine_Name).Find(&result)

		// stockRec.Created_By = result.lUser
		// stockRec.Created_Date = result.ldate
		var m_id int64
		db.Table("st860_medicine_master").Select("id").Where("medicine_name=? and brand=?", stockRec.Medicine_Name, stockRec.Brand).Scan(&m_id)
		res1 := db.Table("st860_medicine_stock").Where("medicine_name = ? and m_id=?", stockRec.Medicine_Name, m_id).Updates(map[string]interface{}{
			"quantity":     stockRec.Quantity,
			"unit_price":   stockRec.Unit_Price, // This should be provided if it's updated
			"updated_by":   stockRec.Updated_By,
			"updated_date": time.Now(),
		})
		if res1.Error != nil {
			resp.Status = "E"
			resp.ErrMessage = "Error" + res1.Error.Error()
			sendResponse(pw, resp)
			return
		}

		resp.Status = "S"                         // Set response status to "S" (success)
		log.Println("Stock updated successfully") // Log success message
		sendResponse(pw, resp)                    // Send the successful response
	} else {
		// Handle methods other than POST
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with 405 Method Not Allowed
	}
}
