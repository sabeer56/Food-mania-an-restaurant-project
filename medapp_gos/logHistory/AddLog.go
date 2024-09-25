package loghistory

import (
	"encoding/json" // Import the JSON package for marshaling and unmarshaling JSON data
	"fmt"
	"io/ioutil" // Import the ioutil package for reading request body
	"log"       // Import the log package for logging errors and information
	"net/http"  // Import the HTTP package for handling HTTP requests and responses
	"time"
	// Import the time package for handling timestamps
)

// Purpose of the Code

// The AddLogs function is designed to handle HTTP POST requests for adding log entries to a database. It processes incoming JSON data representing log records, validates and unmarshals this data, sets a log-in timestamp, and then adds the log entry to the database. The function also handles CORS preflight requests and ensures proper response formatting for both success and error scenarios.
// Request and Response
// Request:

//     Method: POST (for adding log entries) and OPTIONS (for handling CORS preflight requests).
//     Content-Type: application/json
//     Body: A JSON object representing a log entry, which includes fields such as Id, UserId, Type, Role, LogInTime, LogOutTime, Created_By, Created_Date, Updated_By, and Updated_Date.

// Response:

//     Content-Type: application/json
//     Status Code:
//         200 OK for successful POST requests.
//         405 Method Not Allowed for unsupported HTTP methods.
//     Body:

//         Success Response: The response structure is determined by the userLogsResponse type.

//         json

// {
//   "status": "S",
//   "errmsg": "",
//   "userlogs": [
//     {
//       "id": 0,
//       "userId": "",
//       "type": "",
//       "role": "",
//       "logintime": "YYYY-MM-DD HH:MM:SS",
//       "logouttime": "",
//       "created_by": "",
//       "created_date": "",
//       "updated_by": "",
//       "updated_date": ""
//     }
//   ]
// }

// Error Response:

// json

// {
//   "status": "E",
//   "errmsg": "Error: <error_code> <error_description>"
// }

// logs defines the structure for log records
type st860_userlogs2 struct {
	Id           int        `json:"id" gorm:"primaryKey;autoIncrement"`                    // ID of the log entry
	UserId       string     `json:"userId" gorm:"column:userId" `                          // ID of the user associated with the log
	Type         string     `json:"type" gorm:"column:type"`                               // Type of the log entry
	Role         string     `json:"role" gorm:"column:role"`                               // Role of the user associated with the log
	LogIn_Time   time.Time  `json:"login_time" gorm:"column:Login_time;type:time"`         // Timestamp when the user logged in
	LogOut_Time  *time.Time `json:"logout_time" gorm:"column:Logout_time;type:time"`       // Timestamp when the user logged out
	LogIn_Date   time.Time  `json:"login_date" gorm:"column:Login_date;type:date"`         // Date when the user logged in
	LogOut_Date  *time.Time `json:"logout_date" gorm:"column:Logout_date;type:date"`       // Date when the user logged out
	Created_By   string     `json:"created_by" gorm:"column:created_by"`                   // User who created the log entry
	Created_Date time.Time  `json:"created_date" gorm:"column:created_date;type:datetime"` // Date when the log entry was created
	Updated_By   string     `json:"updated_by" gorm:"column:updated_by"`                   // User who last updated the log entry
	Updated_Date *time.Time `json:"updated_date" gorm:"column:updated_date;type:datetime"` // Date when the log entry was last updated
}
type UserLog struct {
	Id          int    `gorm:"column:id" json:"id"`
	UserId      string `gorm:"column:Userid"         json:"Userid"`
	Type        string `gorm:"column:type"    		 json:"type" gorm:"column:type;"`
	Role        string `gorm:"column:role"    		 json:"role" gorm:"column:role"`
	Login_Time  string `gorm:"column:login_time"     json:"login_time"` // Use string if the column is a VARCHAR
	Login_Date  string `gorm:"column:login_date"     json:"login_date"`
	Logout_Time string `gorm:"column:logout_time"    json:"logout_time"`
	Logout_Date string `gorm:"column:logout_date"    json:"logout_date"`
}

// userLogsResponse defines the structure for the response to the client
type userLogsResponse struct {
	ErrMsg   string    `json:"errmsg"`   // Error message, if any
	Status   string    `json:"status"`   // Status of the request ("S" for success, "E" for error)
	UserLogs []UserLog `json:"userlogs"` // Slice of log entries
}

func (st860_userlogs2) TableName() string {
	return "st860_userlogs2"
}

// AddLogs handles the HTTP request to add log data
func AddLogs(pw http.ResponseWriter, pr *http.Request) {
	// Set headers to handle CORS (Cross-Origin Resource Sharing) and content-type
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Credentials", "true")                                                                      // Allow credentials in requests
	pw.Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")                                                                  // Allow POST and OPTIONS HTTP methods
	pw.Header().Set("Content-Type", "application/json")                                                                              // Set content type of the response to JSON
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers in requests

	// Handle preflight OPTIONS request for CORS
	if pr.Method == "OPTIONS" {
		pw.WriteHeader(http.StatusOK) // Respond with a 200 OK status
		return                        // End the function execution
	}

	// Handle POST request to add a log entry
	if pr.Method == "POST" {
		var userLogRec st860_userlogs2 // Declare a variable to hold the log entry data
		var resp userLogsResponse      // Declare a variable to hold the response data

		// Read the request body
		body, err := ioutil.ReadAll(pr.Body) // Read the entire body of the request
		if err != nil {
			log.Println("Error reading body:", err)      // Log the error if reading the body fails
			resp.Status = "E"                            // Set the status to "E" (error)
			resp.ErrMsg = "Error: LHAL01 " + err.Error() // Set the error message
			sendAddLogsResponse(pw, resp)                // Send the error response
			return                                       // End the function execution
		}

		// Unmarshal the JSON body into the logs struct
		err = json.Unmarshal(body, &userLogRec) // Parse the JSON body and populate the userLogRec variable
		if err != nil {
			log.Println("Error unmarshalling body:", err) // Log the error if unmarshalling fails
			resp.Status = "E"                             // Set the status to "E" (error)
			resp.ErrMsg = "Error: LHAL02 " + err.Error()  // Set the error message
			sendAddLogsResponse(pw, resp)                 // Send the error response
			return                                        // End the function execution
		}
		fmt.Println(userLogRec)
		// Add the log entry to the database
		resp = addLogToDatabase(userLogRec) // Call a function to add the log entry to the database
		sendAddLogsResponse(pw, resp)       // Send the response
	} else {
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed) // Respond with a 405 Method Not Allowed status for unsupported methods
	}
}
