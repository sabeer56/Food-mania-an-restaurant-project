package todaysales

import (
	"encoding/json" // For encoding data to JSON format
	"fmt"
	"log"      // For logging errors
	"net/http" // For handling HTTP requests and responses
)

// sendJSONResponse marshals the response and writes it to the HTTP response writer.
func sendJSONResponse(pw http.ResponseWriter, resp interface{}) {
	// Convert the response struct to JSON format
	data, err := json.Marshal(resp)
	fmt.Println(resp)
	if err != nil {
		// Log and handle JSON marshaling errors
		http.Error(pw, "Error creating response JSON: "+err.Error(), http.StatusInternalServerError) // Respond with 500 Internal Server Error
		return
	}

	// Set the Content-Type header to application/json
	pw.Header().Set("Content-Type", "application/json")

	// Set the HTTP status code to 200 OK
	pw.WriteHeader(http.StatusOK)

	// Write the JSON data to the HTTP response writer
	_, err = pw.Write(data)
	if err != nil {
		// Log and handle errors writing the response
		log.Println("Error writing response:", err) // Log the error
	}
}
