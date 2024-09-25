package stocks

import (
	"encoding/json" // Importing the encoding/json package for JSON encoding
	"net/http"      // Importing the net/http package for HTTP handling
)

// sendResponse marshals the response and writes it to the HTTP response writer.
func sendResponse(pw http.ResponseWriter, resp interface{}) {
	// Convert the response object to JSON format
	data, err := json.Marshal(resp)
	if err != nil {
		// If JSON marshaling fails, log the error and send a 500 Internal Server Error response
		http.Error(pw, "Error processing request: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Set the Content-Type header to application/json to indicate that the response is in JSON format
	pw.Header().Set("Content-Type", "application/json")

	// Set the HTTP status code to 200 OK
	pw.WriteHeader(http.StatusOK)

	// Write the JSON data to the response writer
	pw.Write(data)
}
