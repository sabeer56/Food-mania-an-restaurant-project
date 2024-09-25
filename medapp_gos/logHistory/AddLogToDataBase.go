package loghistory

import (
	"fmt"
	"log" // Import the log package for logging errors and messages
	a "medapp_gos/adduser"
	"medapp_gos/database" // Import the database package for database operations
	"time"
	// Import the time package for date and time operations
)

// Purpose of the Code

// The addLogToDatabase function is designed to insert a log entry into the database. It takes a logs struct containing log details, establishes a connection to the database, performs an SQL INSERT operation, and returns a userLogsResponse indicating the success or failure of the operation. The function also handles database connection errors and SQL execution errors, providing appropriate status and error messages.
// Request and Response
// Request:

//     Input: A logs struct containing the log entry details:
//         UserId: ID of the user associated with the log.
//         Type: Type of the log entry.
//         Role: Role of the user.
//         LogInTime: Timestamp of when the user logged in.
//         Created_By: User who created the log entry.
//         Updated_By: User who last updated the log entry.
//     Content-Type: Not directly applicable to this function as it is a backend operation. The logs struct is passed as an argument from another function, such as AddLogs.

// Response:

//     Type: userLogsResponse
//     Content:
//         Status: Indicates whether the operation was successful or failed.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains error details if the operation failed, including a custom error code and description.

// addLogToDatabase inserts log data into the database and returns the response.
func addLogToDatabase(userLogRec st860_userlogs2) userLogsResponse {
	var resp userLogsResponse // Initialize a response object of type userLogsResponse
	resp.Status = "S"         // Set the initial status to "S" for success

	// Establish a connection to the database
	db, err := database.LocalDBConnect() // Call the LocalDBConnect function to get a database connection
	DB, _ := db.DB()
	if err != nil {
		// If there is an error connecting to the database
		log.Println("Database connection error:", err) // Log the database connection error
		resp.Status = "E"                              // Set the status to "E" for error
		resp.ErrMsg = "Error: LHALTD01 " + err.Error() // Set the error message with a custom error code and the error details
		return resp                                    // Return the response object with the error status and message
	} else {
		defer DB.Close()

		// Enable debugging for development purposes (optional)
		// db = db.Debug()
		fmt.Println(100, userLogRec)
		var user a.St860_users
		if err := db.Model(a.St860_users{}).Select("created_by, created_date").Where("userId=?", userLogRec.UserId).First(&user).Error; err != nil {
			// Handle the case where the user is not found or another error occurs
			log.Println("User retrieval error:", err)      // Log the user retrieval error
			resp.Status = "E"                              // Set the status to "E" for error
			resp.ErrMsg = "Error: LHALTD03 " + err.Error() // Set the error message with a custom error code and the error details
			return resp                                    // Return the response object with the error status and message
		}

		// Update the userLogRec struct with the retrieved user details
		userLogRec.Created_By = user.Created_By
		userLogRec.Created_Date = user.Created_Date
		userLogRec.LogIn_Time = time.Now()
		userLogRec.LogIn_Date = time.Now()
		// Insert the log record into the database
		if err := db.Create(&userLogRec).Error; err != nil {
			// If there is an error executing the SQL query
			log.Println("Database insert error:", err)     // Log the database insert error
			resp.Status = "E"                              // Set the status to "E" for error
			resp.ErrMsg = "Error: LHALTD02 " + err.Error() // Set the error message with a custom error code and the error details
		} else {
			// If the insert operation is successful
			log.Println("Inserted successfully") // Log a success message
		}

		return resp // Return the response object with the status and message
	}
}
