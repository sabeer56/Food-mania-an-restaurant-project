package loghistory

import (
	"encoding/json" // Import the encoding/json package to marshal JSON data
	"net/http"      // Import the net/http package to handle HTTP requests and responses
)

// sendResponse marshals the response and writes it to the HTTP response writer.
func sendResponse(pw http.ResponseWriter, resp interface{}) {
	// Marshal the response into JSON format
	data, err := json.Marshal(resp) // Convert the response object to a JSON byte slice
	if err != nil {
		// If marshalling fails, return an error response
		http.Error(pw, "Error processing request: "+err.Error(), http.StatusInternalServerError) // Send a 500 Internal Server Error with the error message
		return                                                                                   // Exit the function
	}

	// Set the Content-Type header for the response
	pw.Header().Set("Content-Type", "application/json") // Specify that the response is in JSON format

	// Write the HTTP status code for a successful response
	pw.WriteHeader(http.StatusOK) // Set the status code to 200 OK

	// Write the JSON data to the response
	pw.Write(data) // Send the JSON data to the client
}
