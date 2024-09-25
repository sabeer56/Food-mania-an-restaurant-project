package adduser

import (
	"encoding/json" // Importing the JSON package for encoding and decoding JSON data
	"io/ioutil"     // Importing ioutil package for reading the request body
	"log"           // Importing the log package for logging errors and information
	"net/http"      // Importing the http package for handling HTTP requests and responses
	"time"
)

// Purpose of the Code:
// This code defines an HTTP handler function `Adduser` which is responsible for handling HTTP POST requests to add a new user to the system.
// It sets appropriate headers for CORS, reads and processes the request body, and interacts with the database to add the user.
// The response is sent back to the client with either success or error information based on the outcome of the operation.

// Request and Response Details:
// - **Request**: The client sends an HTTP POST request with a JSON body containing user details (userId, password, role, and created_by).
// - **Response**: The server responds with a JSON object containing:
//   - `Status`: Indicates whether the operation was successful ("S") or encountered an error ("E").
//   - `ErrMsg`: An error message explaining the failure if an error occurred. This field is empty if the operation was successful.
//   - `UserArr`: An array of user records (not used in this function but included in the response structure).

// Define a struct for user data
type St860_users struct {
	Id           int       `json:"id" gorm:"primaryKey"`
	UserId       string    `json:"userId" gorm:"column:userId" ` // User ID field from the JSON request
	Password     string    `json:"password"`                     // Password field from the JSON request
	Role         string    `json:"role"`                         // User role field from the JSON request
	Created_By   string    `json:"Created_By"`                   // Creator of the user field from the JSON request
	Created_Date time.Time `json:"created_date" gorm:"type:datetime"`
}

// Define a struct for the response format
type GuserResp struct {
	UserArr []St860_users `json:"userArr"` // Array of users for response (not used in this function)
	ErrMsg  string        `json:"errMsg"`  // Error message field for response
	Status  string        `json:"status"`  // Status field for response (e.g., success or error)
}

func (St860_users) TableName() string {
	return "St860_users"
}

// Adduser handles the HTTP request to add a user.
func Adduser(pw http.ResponseWriter, pr *http.Request) {
	// Set response headers to allow cross-origin requests and specify allowed methods and headers
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Credentials", "true")                                                                      // Allow cookies and credentials to be included in the requests
	pw.Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")                                                                  // Allow POST and OPTIONS HTTP methods
	pw.Header().Set("Content-Type", "application/json")                                                                              // Set content type of the response to JSON
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers in requests

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		return // End the function if the request method is OPTIONS (preflight request for CORS)
	}

	// Handle POST request
	if pr.Method == "POST" {
		var luserRec St860_users // Variable to hold the user record from the request
		var lresp GuserResp      // Variable to hold the response

		// Read the body of the request
		body, err := ioutil.ReadAll(pr.Body)
		if err != nil {
			log.Println("Error reading body:", err)       // Log error if reading body fails
			lresp.Status = "E"                            // Set status to error
			lresp.ErrMsg = "Error : AAU01 " + err.Error() // Set error message
			sendResponse(pw, lresp)                       // Send the response with error details
			return                                        // End the function
		}

		// Unmarshal the JSON body into the Gusers struct
		err = json.Unmarshal(body, &luserRec)
		if err != nil {
			log.Println("Error unmarshalling body:", err) // Log error if unmarshalling fails
			lresp.Status = "E"                            // Set status to error
			lresp.ErrMsg = "Error : AAU02 " + err.Error() // Set error message
			sendResponse(pw, lresp)                       // Send the response with error details
			return                                        // End the function
		}

		// Call function to add the user to the database and get the response
		lresp = addUserToDatabase(&luserRec)
		sendResponse(pw, lresp) // Send the response with the result of the addUserToDatabase function
	}
}
