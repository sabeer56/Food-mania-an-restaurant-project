package loghistory

import (
	// Import the encoding/json package to marshal and unmarshal JSON data
	// Import the ioutil package for reading the request body

	"net/http" // Import the net/http package to handle HTTP requests and responses
)

// Purpose :

// The UpdateLogHistory function is designed to handle HTTP PUT requests for updating log entries in the database. It processes incoming JSON data to update existing log records, manages CORS (Cross-Origin Resource Sharing) headers, handles potential errors, and sends an appropriate JSON response back to the client. This function is critical for modifying log entries and ensuring that updates are properly reflected in the database.
// Request and Response
// Request:

//     HTTP Method: PUT
//     Endpoint: The function processes PUT requests aimed at updating log history.
//     Headers:
//         Access-Control-Allow-Origin: "*" - Allows requests from any origin.
//         Access-Control-Allow-Credentials: "true" - Permits credentials to be sent with the request.
//         Access-Control-Allow-Methods: "PUT,OPTIONS" - Allows only PUT and OPTIONS methods.
//         Content-Type: "application/json" - Specifies that the content type of the response is JSON.
//         Access-Control-Allow-Headers: "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization" - Specifies allowed headers in requests.

// Response:

//     Type: userLogsResponse
//     Content:
//         Status: Indicates the result of the update operation.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains an error message if the update fails, including a custom error code and description.

// UpdateLogHistory handles the HTTP request to update log history.
func UpdateLogHistory(pw http.ResponseWriter, pr *http.Request) {
	// Set headers to handle CORS and specify the content type
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Methods", "PUT,OPTIONS")                                                                   // Allow POST and OPTIONS HTTP methods
	pw.Header().Set("Content-Type", "application/json")                                                                              // Set content type to JSON
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers in requests

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		return // For OPTIONS requests, just return without further processing
	}

	// Handle PUT request
	if pr.Method == "PUT" {

		var resp userLogsResponse // Define a variable to hold the response

		// Update the log history in the database
		resp = updateLogHistoryInDatabase() // Call the function to update the log history in the database and get the response
		sendResponse(pw, resp)              // Send the response with the result of the update operation
	} else {
		// Handle methods other than PUT
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with a 405 Method Not Allowed status
	}
}
