package bills

import (
	"encoding/json" // Importing the JSON package for encoding data into JSON format
	"net/http"      // Importing the HTTP package for handling HTTP requests and responses
)

// sendResponse marshals the response and writes it to the HTTP response writer.
func sendResponse(pw http.ResponseWriter, resp GBillResponse) {
	// Marshal the response object into JSON format
	data, err := json.Marshal(resp)
	if err != nil {
		// If marshalling fails, respond with a 500 Internal Server Error
		http.Error(pw, "Error creating response JSON: "+err.Error(), http.StatusInternalServerError)
		return // End function execution
	}

	// Set the Content-Type header to application/json to indicate JSON response
	pw.Header().Set("Content-Type", "application/json")

	// Set the HTTP status code to 200 OK
	pw.WriteHeader(http.StatusOK)

	// Write the JSON data to the HTTP response body
	pw.Write(data)
}
