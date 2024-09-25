package login

import (
	"net/http"
)

// Purpose :

// The Getuser function is an HTTP handler designed to process GET requests for retrieving user details. It sets the appropriate HTTP headers for CORS (Cross-Origin Resource Sharing) and ensures that only GET and OPTIONS methods are allowed. Upon receiving a GET request, it calls a function to fetch user details, handles potential errors, and sends the appropriate response back to the client. If the request method is not GET, it responds with a "Method Not Allowed" error.
// Request and Response
// Request:

//     Method: GET
//     Purpose: To retrieve user details from the server.

// Response:

//     Type: The response type is likely JSON, based on the usage of sendResponse function.
//     Content:
//         Status: Indicates the result of the request.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains an error message if an error occurs, including a custom error code and description.

// Getuser is the HTTP handler function for the GET request to retrieve user details.
func LoginApi(pw http.ResponseWriter, pr *http.Request) {
	// Set CORS headers to allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Origin", "*")
	pw.Header().Set("Access-Control-Allow-Credentials", "true")
	pw.Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")
	pw.Header().Set("Content-Type", "application/json")
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")

	// Check if the request method is GET
	if pr.Method == "GET" {
		// Fetch user details
		resp, err := fetchUsers() // Call the fetchUsers function to retrieve user details
		if err != nil {
			// If there is an error fetching users, set the error message and status
			resp.ErrMsg = "Error : LGU01" + err.Error() // Set error message with a specific code
			resp.Status = "E"                           // Set status to "Error"
			// Send the response with the error status and message
			sendResponse(pw, resp) // Call sendResponse to send the error response to the client
			return                 // Exit the function to prevent further processing
		}

		// Send the successful response
		sendResponse(pw, resp) // Call sendResponse to send the successful response to the client
	} else {
		// If the request method is not GET, respond with "Method Not Allowed"
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Return an HTTP 405 Method Not Allowed error
	}
}
