package loghistory

import (
	"encoding/json" // Import the encoding/json package to marshal Go objects into JSON
	"net/http"      // Import the net/http package to handle HTTP requests and responses
)

// sendUserLogsResponse marshals the response and writes it to the HTTP response writer.
func sendUserLogsResponse(pw http.ResponseWriter, resp userLogsResponse) {
	// Marshal the response object into JSON
	data, err := json.Marshal(resp) // Convert the 'resp' object to JSON format
	if err != nil {
		// Handle error if JSON marshalling fails
		http.Error(pw, "Error creating response JSON: "+err.Error(), http.StatusInternalServerError) // Respond with a 500 Internal Server Error and error message
		return                                                                                       // Exit the function if there was an error
	}

	// Set HTTP response headers and status code
	pw.WriteHeader(http.StatusOK) // Set the status code to 200 OK

	// Write the JSON data to the response body
	pw.Write(data) // Write the JSON-encoded data to the response writer
}
