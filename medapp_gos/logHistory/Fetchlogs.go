package loghistory

import (
	"log"                   // Import the log package for logging errors and messages
	d "medapp_gos/database" // Import the database package for database operations
)

// Purpose :

// The fetchUserLogs function is designed to retrieve user log entries from a database and return them as part of a structured response. It connects to the database, executes a query to fetch log records, processes the results, and returns a userLogsResponse object indicating the success or failure of the operation along with the retrieved log data.
// Request and Response
// Request:

//     Input: This function does not take any parameters directly; it operates based on internal database interactions and returns all user log entries available in the database.
//     Content-Type: Not directly applicable to this function as it performs a backend operation.

// Response:

//     Type: userLogsResponse
//     Content:
//         Status: Indicates whether the operation was successful or encountered an error.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains error details if the operation failed, including a custom error code and description.
//         UserLogs: A slice of logs structs representing the retrieved user log entries.

// fetchUserLogs retrieves user logs from the database and returns the response.
func fetchUserLogs() userLogsResponse {
	var resp userLogsResponse // Initialize a response object of type userLogsResponse
	resp.Status = "S"         // Set the initial status to "S" for success

	// Connect to the database
	db, err := d.LocalDBConnect() // Call the LocalDBConnect function from the database package to get a database connection
	DB, _ := db.DB()
	if err != nil {
		// If there is an error connecting to the database
		log.Println("fetchUsers error:", err)          // Log the connection error
		resp.ErrMsg = "Error : LHFUL01 " + err.Error() // Set the error message with a custom error code and the error details
		resp.Status = "E"                              // Set the status to "E" for error
		return resp                                    // Return the response object with the error status and message
	} else {
		defer DB.Close()
		var result1 []UserLog
		res := db.Table("st860_userlogs2").
			Select("id,Userid, type, role, login_time,login_date, logout_time,logout_date").
			Scan(&result1)
		// Query to fetch user logs
		if res.Error != nil {
			resp.ErrMsg = "Error : LHFUL01 " + res.Error.Error() // Set the error message with a custom error code and the error details
			resp.Status = "E"                                    // Set the status to "E" for error
			return resp                                          // Return the response object with the error status and message
		}

		resp.UserLogs = result1
		return resp // Return the response object with the status and any user logs retrieved
	}

}
