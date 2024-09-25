package adduser

import (
	"log"                 // Importing the log package for logging errors and information
	"medapp_gos/database" // Importing the custom database package for database operations
	"time"
	// Importing the time package for formatting dates
)

// Purpose of the Code:
// The `addUserToDatabase` function is responsible for inserting a new user record into the database.
// It handles database connection, prepares and executes an SQL insertion command, and manages errors.
// The function returns a response object indicating the success or failure of the database operation.

// Request and Response Details:
// - **Request**: This function does not directly handle HTTP requests. It is called by the `Adduser` handler function which provides the user data.
// - **Response**:
//   - **Status**: Indicates whether the database operation was successful ("S") or encountered an error ("E").
//   - **ErrMsg**: Contains an error message with a specific code if an error occurs. This field is empty if the operation was successful.

// Response Commands:
// - **`lresp.Status = "E"`**: Sets the status to "Error" when an issue is encountered (e.g., database connection failure or SQL execution failure).
// - **`lresp.ErrMsg = "Error : AUTDB01 " + err.Error()`**: Sets the error message with a specific error code and details about the issue.
// - **`log.Println(lresp.ErrMsg)`**: Logs the error message for debugging and monitoring purposes.
// - **`return lresp`**: Returns the response object containing the status and error message to the caller.

// addUserToDatabase handles inserting a new user record into the database.
func addUserToDatabase(userRec *St860_users) GuserResp {
	var lresp GuserResp // Create a response object to store status and error messages
	lresp.Status = "S"  // Initialize the response status to "Success"

	// Connect to the database using a custom function from the database package
	db, err := database.LocalDBConnect()
	DB, _ := db.DB()
	if err != nil {
		lresp.Status = "E"                              // Set status to "Error" if the connection fails
		lresp.ErrMsg = "Error : AUTDB01 " + err.Error() // Set the error message with a specific code
		log.Println(lresp.ErrMsg)                       // Log the error message
		return lresp                                    // Return the response object with the error details
	}
	defer DB.Close()
	if err := db.AutoMigrate(&St860_users{}); err != nil {
		log.Fatalf("failed to migrate database schema: %v", err)
	}

	userRec.Created_Date = time.Now()
	res := db.Create(&userRec)
	if res.Error != nil {
		lresp.Status = "E"                                    // Set status to "Error" if the connection fails
		lresp.ErrMsg = "Error : AUTDB02 " + res.Error.Error() // Set the error message with a specific code
		log.Println(lresp.ErrMsg)                             // Log the error message
		return lresp                                          // Return the response object with the error details
	}
	log.Println("Inserted successfully") // Log a success message if the insertion is successful
	return lresp                         // Return the response object with the success status
}
