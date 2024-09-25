package adduser

import (
	"encoding/json" // Importing the JSON package for encoding data into JSON format
	"fmt"           // Importing the fmt package for formatted I/O operations
	"net/http"      // Importing the http package for HTTP handling
)

// sendResponse sends an HTTP response with a JSON-encoded body.
func sendResponse(pw http.ResponseWriter, presp GuserResp) {
	// Marshal the GuserResp object into a JSON format
	data, err := json.Marshal(presp)
	if err != nil {
		// If marshalling fails, send an HTTP error response with status code 500 (Internal Server Error)
		http.Error(pw, "Error marshaling response: "+err.Error(), http.StatusInternalServerError)
		return // Exit the function to avoid sending further response
	}

	// Set the Content-Type header of the response to "application/json"
	pw.Header().Set("Content-Type", "application/json")

	// Set the HTTP status code of the response to 200 (OK)
	pw.WriteHeader(http.StatusOK)

	// Write the JSON data to the response body
	fmt.Fprintln(pw, string(data))
}
