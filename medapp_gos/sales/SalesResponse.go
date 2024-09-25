package sales

import (
	"encoding/json" // Importing the encoding/json package for JSON encoding
	"net/http"      // Importing the net/http package for HTTP handling
)

// respondWithJSON marshals the response and writes it to the HTTP response writer.
func respondWithJSON(pw http.ResponseWriter, resp SalesResponse) {
	// Convert the SalesResponse struct into JSON format
	data, err := json.Marshal(resp)
	if err != nil {
		// If there is an error during JSON encoding, respond with a 500 Internal Server Error
		http.Error(pw, "Error creating response JSON: "+err.Error(), http.StatusInternalServerError)
		return
	}
	// Set the Content-Type header to indicate that the response is JSON
	pw.Header().Set("Content-Type", "application/json")
	// Set the HTTP status code to 200 OK to indicate successful processing
	pw.WriteHeader(http.StatusOK)
	// Write the JSON-encoded response data to the HTTP response writer
	pw.Write(data)
}
