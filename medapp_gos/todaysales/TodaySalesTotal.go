package todaysales

import (
	"fmt"
	"log"                   // For logging errors and informational messages
	d "medapp_gos/database" // Custom package for database operations
	"net/http"              // For handling HTTP requests and responses
)

/*
Package `todaysales` provides functionality for handling HTTP GET requests to retrieve sales data for the current day.

The `TodaySales` function is designed to process GET requests to return the total sales amount for the specified date. This function interacts with the database to aggregate and fetch sales data and formats it for JSON response.

### Purpose

The primary purpose of the `TodaySales` function is to:
1. Handle HTTP GET requests to retrieve and return the total sales amount for a given date.
2. Manage CORS (Cross-Origin Resource Sharing) headers to support requests from various origins.
3. Validate query parameters and handle database interactions to provide accurate sales data.
4. Return the sales data in a structured JSON format, including handling and reporting any errors.

### Request Handling

1. **CORS Configuration:** The function sets the following headers to manage CORS:
   - `Access-Control-Allow-Origin`: Allows requests from any origin (`*`).
   - `Access-Control-Allow-Methods`: Specifies allowed HTTP methods (`GET, OPTIONS`).
   - `Access-Control-Allow-Headers`: Lists allowed request headers.

2. **Preflight Request Handling:** If the request method is `OPTIONS`, it responds with a `200 OK` status, which is part of handling CORS preflight requests.

3. **GET Request Processing:**
   - **Database Connection:** Connects to the local database using `d.LocalDBConnect()`. Handles errors related to database connection and provides an appropriate response.
   - **Date Parameter Validation:** Retrieves the `date` parameter from the query string. If the `date` parameter is missing, it responds with an error.
   - **Database Query:** Executes a SQL query to calculate the total sales amount for the specified date. Uses `SUM(netprice)` to aggregate the sales amounts from the `st860_bill_master_details` table.
   - **Result Processing:** Scans the result of the query to extract the total sales amount. Handles errors related to scanning the result and provides an error response if needed.

### Response Handling

1. **Error Responses:** If any error occurs during request processing, such as database connection issues, missing date parameters, or query execution errors:
   - Logs the error.
   - Sets the response status to `"E"` (error).
   - Provides a detailed error message in the `ErrMsg` field.
   - Sends the error response using `sendJSONResponse(pw, lresp)`.

2. **Success Responses:** If the data retrieval is successful:
   - Sets the response status to `"S"` (success).
   - Includes the total sales amount in the `TotalSale` field.
   - Sends the successful response using `sendJSONResponse(pw, lresp)`.
   - Logs a success message indicating that the sales data was successfully retrieved.

3. **Method Not Allowed:** If the request method is not `GET`, it responds with a `405 Method Not Allowed` status.

### Response Commands

- `sendJSONResponse(pw, lresp)`:
  - A utility function used to encode the `TodaySalesResponse` struct as JSON and write it to the `pw` (response writer). This function ensures that the response is properly formatted and sent back to the client.

The `TodaySales` function provides a robust mechanism for retrieving and returning daily sales data, handling various potential errors, and ensuring proper response formatting.
*/

// TodaySalesResponse represents the response structure for sales data.
type TodaySalesResponse struct {
	Status       string      `json:"status"`           // Status of the request, "S" for success, "E" for error
	ErrMsg       string      `json:"errMsg,omitempty"` // Optional error message, if any
	TotalSale    []totalsale `json:"totalSale"`        // Total sales amount for today
	MonthlySales []monthsale `json:"monthlysales"`
}
type totalsale struct {
	TodayTotalSale float64 `json:"todaytotalsale" gorm:"column:total_net_price" `
	BillerName     string  `json:"login_id" gorm:"column:Login_id"`
}
type monthsale struct {
	MonthlyTotalSale float64 `json:"monthlytotalsale" gorm:"column:bill_amount"`
	MBillerName      string  `json:"login_id" gorm:"column:Login_id"`
}

func TotalSales(pw http.ResponseWriter, pr *http.Request) {
	// Set headers for CORS (Cross-Origin Resource Sharing) and content-type
	pw.Header().Set("Access-Control-Allow-Origin", "*")
	pw.Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		pw.WriteHeader(http.StatusOK)
		return
	}

	// Handle GET request to retrieve today's sales data
	if pr.Method == "GET" {
		var lresp TodaySalesResponse
		lresp.Status = "S"

		// Connect to the database
		db, err := d.LocalDBConnect()
		DB, _ := db.DB()
		if err != nil {
			log.Println("Error connecting to the database:", err)
			lresp.Status = "E"
			lresp.ErrMsg = "Error: TTS01 " + err.Error()
			sendJSONResponse(pw, lresp)
			return
		}
		defer DB.Close()
		today := pr.URL.Query().Get("date")
		fmt.Println(100, today)
		var results []totalsale
		res := db.Table("st860_bill_master").Select("Login_id, SUM(netprice) AS total_net_price").Where("bill_date =?", today).Group("Login_id").Scan(&results)

		if res.Error != nil {
			log.Println("Error executing query:", err)
			lresp.Status = "E"
			lresp.ErrMsg = "Error: TTS02 " + res.Error.Error()
			sendJSONResponse(pw, lresp)
			return
		}
		lresp.TotalSale = results
		// Query for monthly sales data
		var results1 []monthsale
		res1 := db.Table("st860_bill_master").
			Select("Login_id, IFNULL(SUM(netprice), 0) AS bill_amount").
			Where("YEAR(bill_date) = YEAR(CURDATE())").
			Where("MONTH(bill_date) = MONTH(CURDATE())").
			Group("Login_id").
			Scan(&results1)

		if res1.Error != nil {
			log.Println("Error executing query:", err)
			lresp.Status = "E"
			lresp.ErrMsg = "Error: TTS02 " + res1.Error.Error()
			sendJSONResponse(pw, lresp)
			return
		}
		lresp.MonthlySales = results1
		// Send the successful response with the total sales data
		sendJSONResponse(pw, lresp)
		log.Println("Sales data retrieved successfully")
	} else {
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed)
	}
}
