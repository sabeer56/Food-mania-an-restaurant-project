package loghistory

import (
	"encoding/json" // Import the JSON package for marshaling data into JSON format
	"net/http"      // Import the HTTP package for handling HTTP requests and responses
)

// sendAddLogsResponse marshals the response into JSON format and writes it to the HTTP response writer.
func sendAddLogsResponse(pw http.ResponseWriter, resp userLogsResponse) {
	// Convert the response struct to JSON
	data, err := json.Marshal(resp) // Marshal the userLogsResponse struct into a JSON byte slice
	if err != nil {
		// If there is an error during marshaling, send an internal server error response
		http.Error(pw, "Error creating response JSON: "+err.Error(), http.StatusInternalServerError) // Send a 500 Internal Server Error response with the error message
		return                                                                                       // Exit the function
	}

	// Set the response status and content type
	pw.WriteHeader(http.StatusOK) // Set the HTTP status code to 200 OK
	pw.Write(data)                // Write the JSON data to the response body
}
