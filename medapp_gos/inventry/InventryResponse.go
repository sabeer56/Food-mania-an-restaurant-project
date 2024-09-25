package inventry

import (
	"encoding/json"
	"net/http"
)

// sendJSONResponse marshals the response object to JSON and writes it to the HTTP response writer
func sendJSONResponse(pw http.ResponseWriter, resp CurrentInventryResponse) {
	data, err := json.Marshal(resp) // Convert the response object to JSON format
	if err != nil {
		http.Error(pw, "Error creating response JSON: "+err.Error(), http.StatusInternalServerError) // Respond with a 500 Internal Server Error if JSON marshaling fails
		return                                                                                       // End the function execution
	}
	pw.Header().Set("Content-Type", "application/json") // Set the Content-Type header to application/json
	pw.WriteHeader(http.StatusOK)                       // Set the HTTP status code to 200 OK
	pw.Write(data)                                      // Write the JSON data to the HTTP response body
}
