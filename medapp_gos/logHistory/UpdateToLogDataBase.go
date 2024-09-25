package loghistory

import (
	"log"
	"medapp_gos/database"
	"time"

	"gorm.io/gorm"
)

// Purpose :

// The updateLogHistoryInDatabase function updates the logout time of the most recent log entry for a specified user in the database. It is part of the logging management system that allows modifying existing log records, specifically setting the logout time to the current timestamp. The function ensures proper database connection handling, error management, and logs both success and error messages for diagnostic purposes.
// Request and Response
// Request:

//     Input:
//         userLogRec: A logs struct containing:
//             UserId: The ID of the user whose log entry is being updated.
//             LogOutTime: The logout time to be set. In this function, it is assigned the current timestamp.

// Response:

//     Type: userLogsResponse
//     Content:
//         Status: Indicates whether the update operation was successful or if an error occurred.
//             "S" for success.
//             "E" for error.
//         ErrMsg: Contains an error message if the update fails, including a custom error code and description.

// updateLogHistoryInDatabase updates the log history in the database and returns the response.
func updateLogHistoryInDatabase() userLogsResponse {
	var resp userLogsResponse // Initialize the response object
	resp.Status = "S"         // Set the initial status to "Success"

	// Connect to the database
	db, err := database.LocalDBConnect() // Call the LocalDBConnect function to establish a database connection
	DB, _ := db.DB()
	if err != nil {
		// If connection fails, log the error and set response status to "Error"
		log.Println("Database connection error:", err) // Log the connection error
		resp.Status = "E"                              // Set the response status to "Error"
		resp.ErrMsg = "Error : LULHID01" + err.Error() // Set the error message with a code
		return resp                                    // Return the response object with the error status and message
	} else {
		defer DB.Close()
		res := db.Model(&st860_userlogs2{}).Where("id=(SELECT max(id) FROM st860_userlogs2 )").Updates(map[string]interface{}{
			"logout_time": time.Now(),
			"logout_date": gorm.Expr("CURRENT_DATE()"),
		})

		if res.Error != nil {
			// If execution fails, log the error and set response status to "Error"
			log.Println("Error executing SQL:", err)             // Log the SQL execution error
			resp.Status = "E"                                    // Set the response status to "Error"
			resp.ErrMsg = "Error : LULHID03" + res.Error.Error() // Set the error message with a code
		} else {
			// If update is successful, log success message
			log.Println("-- Updated successfully  -- ") // Log a success message
		}

		return resp // Return the response object with the status and any error message
	}

}
