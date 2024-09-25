package login

import (
	"encoding/json"
	"fmt"
	"log"
	a "medapp_gos/adduser"
	d "medapp_gos/database"
	"net/http"
)

// Purpose :

// The code in the login package defines functions and structures for retrieving user details from the database and sending the response back to the client.

//     fetchUsers Function: Connects to the database, retrieves user details, and populates a response structure with the user data or an error message if something goes wrong.
//     sendResponse Function: Takes a response structure, marshals it to JSON format, and writes it to the HTTP response writer. This function ensures that the response is properly formatted and sent back to the client.

// Request and Response
// Request:

//     Method: GET
//     Purpose: To retrieve user details from the server.

// Response:

//     Type: JSON
//     Content:
//         Status: Indicates the result of the request.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains an error message if an error occurs, including a custom error code and description.
//         UserArr: An array of user objects, where each user object contains:
//             UserId (string): User ID.
//             Password (string): User password.
//             Role (string): User role.

// Define the structure for user details

// Define the structure for the response
type GLoginResp struct {
	UserArr []a.St860_users `json:"userArr"` // Array of users
	ErrMsg  string          `json:"errMsg"`  // Error message
	Status  string          `json:"status"`  // Status of the response
}

var resp GLoginResp // Initialize a variable to hold response data

// fetchUsers retrieves user details from the database and populates the response.
func fetchUsers() (GLoginResp, error) {
	resp.Status = "S" // Set status to "Success" initially

	// Connect to the database
	db, err := d.LocalDBConnect()
	DB, _ := db.DB()
	if err != nil {
		log.Println("fetchUsers error: Database connection failed -", err) // Log the database connection error
		resp.ErrMsg = "Error : LFU01" + err.Error()                        // Set error message with a specific code
		resp.Status = "E"                                                  // Set status to "Error"
		return resp, err                                                   // Return the response and the error
	}
	defer DB.Close()
	var users []a.St860_users
	res := db.Debug().Select("id,userId, password, role").Find(&users)
	if res.Error != nil {
		resp.Status = "E"
		resp.ErrMsg = "Error " + res.Error.Error()
		return resp, res.Error
	}
	// Create the response with user details
	response := GLoginResp{
		Status:  "S",       // Set status to "Success"
		ErrMsg:  "success", // Set success message
		UserArr: users,     // Assign the user list to the response
	}
	fmt.Println("response:", response) // Log the response for debugging
	return response, nil               // Return the response and no error
}

// sendResponse marshals the response and writes it to the HTTP response writer.
func sendResponse(pw http.ResponseWriter, resp GLoginResp) {
	// Set the Content-Type header to application/json
	pw.Header().Set("Content-Type", "application/json") // Specify that the response is JSON

	// Marshal the response to JSON
	data, err := json.Marshal(resp) // Convert the response object to JSON
	if err != nil {
		// Handle JSON marshaling errors
		http.Error(pw, "Error marshaling response: "+err.Error(), http.StatusInternalServerError) // Return an error response if JSON conversion fails
		return                                                                                    // Exit the function
	}

	// Write the JSON response to the HTTP response writer
	pw.WriteHeader(http.StatusOK)  // Set the HTTP status code to 200 OK
	fmt.Fprintln(pw, string(data)) // Write the JSON data to the response writer
}
