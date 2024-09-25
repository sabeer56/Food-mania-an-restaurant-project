package loghistory

import (
	"log"                   // Import the log package for logging errors and messages
	d "medapp_gos/database" // Import the database package for database connection functions
	"net/http"              // Import the net/http package for handling HTTP requests and responses
)

// Purpose of the Code

// The GetuserLogs function is designed to handle HTTP requests for retrieving user log entries from the database. It sets up appropriate CORS headers, processes HTTP GET requests to fetch user logs, handles errors related to database connectivity, and returns the data in a structured JSON format. This function is used to serve log data to clients, typically for viewing or analyzing user activity within an application.
// Request and Response
// Request:

//     HTTP Method: GET
//     Endpoint: The function handles GET requests aimed at retrieving user logs.
//     Headers:
//         Access-Control-Allow-Origin: "*" - Allows requests from any origin.
//         Access-Control-Allow-Methods: "GET,OPTIONS" - Permits GET and OPTIONS methods.
//         Access-Control-Allow-Headers: "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization" - Specifies allowed headers in requests.

// Response:

//     Type: userLogsResponse
//     Content:
//         Status: Indicates whether the operation was successful or encountered an error.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains an error message if the operation failed, including a custom error code and description.
//         UserLogs: A slice of logs structs representing the retrieved user log entries (only included if the operation is successful).

// GetuserLogs handles the HTTP request to get user logs.
func GetuserLogs(pw http.ResponseWriter, pr *http.Request) {
	// Set headers for CORS and content-type
	pw.Header().Set("Access-Control-Allow-Origin", "*")
	pw.Header().Set("Access-Control-Allow-Credentials", "true")
	pw.Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")
	pw.Header().Set("Content-Type", "application/json")
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		return // If the method is OPTIONS, respond without doing any further processing
	}

	// Handle GET request
	if pr.Method == "GET" {
		var resp userLogsResponse // Initialize a response object of type userLogsResponse
		resp.Status = "S"         // Set the initial status to "S" for success

		// Connect to the database
		_, err := d.LocalDBConnect() // Call the LocalDBConnect function from the database package to get a database connection
		if err != nil {
			// If there is an error connecting to the database
			log.Println("Database connection error:", err) // Log the connection error
			resp.ErrMsg = "Error : LHGUL01 " + err.Error() // Set the error message with a custom error code and the error details
			resp.Status = "E"                              // Set the status to "E" for error
			sendUserLogsResponse(pw, resp)                 // Send the error response to the client
			return                                         // Exit the function after sending the response
		}

		resp = fetchUserLogs() // Call the fetchUserLogs function to retrieve user logs from the database

		// Send the response with user logs to the client
		sendUserLogsResponse(pw, resp) // Send the successful response to the client with user logs
	} else {
		// If the HTTP method is not GET, return a 405 Method Not Allowed status
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with a "Method not allowed" error
	}
}
