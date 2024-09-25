package stocks

import (
	"encoding/json"         // Importing the encoding/json package for JSON encoding and decoding
	"io/ioutil"             // Importing the ioutil package for reading the request body
	"log"                   // Importing the log package for logging errors and information
	d "medapp_gos/database" // Importing the database package for database operations
	"net/http"              // Importing the net/http package for HTTP handling
	"time"                  // Importing the time package for working with dates and times
)

// Purpose :

// The code in the stocks package is designed to handle HTTP POST requests for adding stock data into a database. It receives stock information in JSON format, processes the data, and inserts it into the database. If the operation is successful, it returns a success response; otherwise, it returns an error message.
// Request and Response
// Request:

//     Method: POST
//     Endpoint: (Assumed endpoint would be something like /stocks/add)
//     Content-Type: application/json
//     Body: JSON object representing the stock data, which should include:
//         medicine_name (string): Name of the medicine.
//         brand (string): Brand of the medicine.
//         quantity (int): Quantity of the medicine (though this field is not used in the current SQL query).
//         unit_price (int): Unit price of the medicine (though this field is not used in the current SQL query).
//         Created_By (string): User who is adding the record.

// Response:

//     Type: JSON
//     Structure:
//         Status: Indicates the result of the request.
//             "S" for success.
//             "E" for error.
//         ErrMessage: Contains an optional error message if an error occurs, including a custom error code and description.
//         StockArr: This field is not used in the current implementation, but it could be included for consistency if needed in other operations.

// Stock represents the structure of the stock data.

type St860_medicine_stock struct {
	Id             int                   `gorm:"primaryKey"`
	Medicine_Name  string                `json:"medicine_name" gorm:"column:medicine_name"` // Medicine name
	Quantity       int                   `json:"quantity" gorm:"column:quantity"`           // Quantity of the medicine

	M_Id           int64                 `json:"m_id" gorm:"column:m_id"`
	Unit_Price     int                   `json:"unit_price" gorm:"column:unit_price"` // Unit price of the medicine
	Created_By     string                `json:"created_by" gorm:"column:created_by"` // User who created the record
	Created_Date   time.Time             `json:"created_date" gorm:"type:date;column:created_date"`
	Updated_By     string                `json:"updated_by" gorm:"column:updated_by"` // User who last updated the record
	Updated_Date   *time.Time            `json:"updated_date" gorm:"type:date;column:updated_date"`
	MedicineMaster st860_medicine_master `gorm:"foreignKey:Medicine_Name;references:Medicine_Name"`
}
type St860_medicine_stock1 struct {
	Id             int                   `gorm:"primaryKey"`
	Medicine_Name  string                `json:"medicine_name" gorm:"column:medicine_name"` // Medicine name
	Quantity       int                   `json:"quantity" gorm:"column:quantity"`           // Quantity of the medicine
	Brand           string               `json:"brand"`
	M_Id           int64                 `json:"m_id" gorm:"column:m_id"`
	Unit_Price     int                   `json:"unit_price" gorm:"column:unit_price"` // Unit price of the medicine
	Created_By     string                `json:"created_by" gorm:"column:created_by"` // User who created the record
	Created_Date   time.Time             `json:"created_date" gorm:"type:date;column:created_date"`
	Updated_By     string                `json:"updated_by" gorm:"column:updated_by"` // User who last updated the record
	Updated_Date   *time.Time            `json:"updated_date" gorm:"type:date;column:updated_date"`
	MedicineMaster st860_medicine_master `gorm:"foreignKey:Medicine_Name;references:Medicine_Name"`
}
type Result struct {
	Medicine_Name string `json:"medicine_name"` // Medicine name
	Quantity      int    `json:"quantity" `     // Quantity of the medicine
	Unit_Price    int    `json:"unit_price"`
	Brand         string `json:"brand"`
}
type st860_medicine_master struct {
	Id            int       `gorm:"primaryKey;column:id;AutoIncrement"`
	Medicine_Name string    `json:"medicine_name" gorm:"column:medicine_name"` // Medicine name
	Brand         string    `json:"brand" gorm:"column:brand"`                 // Brand of the medicine
	Created_By    string    `json:"created_by" gorm:"column:created_by"`       // User who created the record
	Created_Date  time.Time `json:"created_date" gorm:"type:date;column:created_date"`
	Updated_By    string    `json:"updated_by" gorm:"column:updated_by"` // User who last updated the record
	Updated_Date  time.Time `json:"updated_date" gorm:"type:date;column:updated_date"`
}

// StockResponse represents the structure of the response for stock operations.
type StockResponse struct {
	StockArr   []Result `json:"stockArr"`   // Array of Stock records
	ErrMessage string   `json:"errmessage"` // Error message if any
	Status     string   `json:"status"`     // Status of the operation (e.g., "S" for success, "E" for error)
}

func (St860_medicine_stock) TableName() string {
	return "St860_medicine_stock"
}
func (st860_medicine_master) TableName1() string {
	return "st860_medicine_master"
}

// AddStocks handles the HTTP request to add stock data.
func AddStocks(pw http.ResponseWriter, pr *http.Request) {
	// Set headers to allow cross-origin requests and define allowed methods and headers
	pw.Header().Set("Access-Control-Allow-Origin", "*")                                                                              // Allow requests from any origin
	pw.Header().Set("Access-Control-Allow-Credentials", "true")                                                                      // Allow cookies and credentials to be included in the requests
	pw.Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")                                                                  // Allow POST and OPTIONS HTTP methods
	pw.Header().Set("Content-Type", "application/json")                                                                              // Set content type of the response to JSON
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization") // Allow specific headers in requests

	// Handle preflight OPTIONS request
	if pr.Method == "OPTIONS" {
		return
	}

	// Handle POST request for adding stock data
	if pr.Method == "POST" {
		var masterRec st860_medicine_master
		var stockRec St860_medicine_stock
		var resp StockResponse // Variable to hold the response

		// Read the request body
		body, err := ioutil.ReadAll(pr.Body)
		if err != nil {
			log.Println("Error reading body:", err)          // Log error if reading body fails
			resp.Status = "E"                                // Set status to error
			resp.ErrMessage = "Error : SAS01 " + err.Error() // Set error message
			sendResponse(pw, resp)                           // Send error response
			return
		}

		// Unmarshal JSON body into stockRec
		err = json.Unmarshal(body, &masterRec)
		if err != nil {
			log.Println("Error unmarshalling JSON:", err)    // Log error if JSON unmarshalling fails
			resp.Status = "E"                                // Set status to error
			resp.ErrMessage = "Error : SAS02 " + err.Error() // Set error message
			sendResponse(pw, resp)                           // Send error response
			return
		}

		// Add stock data to the database and get the response
		resp = addStockToDatabase(masterRec, stockRec)
		sendResponse(pw, resp) // Send response
		return
	}

	// Handle method not allowed for methods other than POST
	http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed)
}
func addStockToDatabase(masterRec st860_medicine_master, stockRec St860_medicine_stock) StockResponse {
	var resp StockResponse
	resp.Status = "S" // Set initial status to success

	// Connect to the database
	db, err := d.LocalDBConnect()
	if err != nil {
		log.Println("Database connection error:", err)
		resp.Status = "E"
		resp.ErrMessage = "Error: SASTD01 " + err.Error()
		return resp
	}
	DB, err := db.DB()
	defer DB.Close() // Ensure database connection is closed

	// Migrate database schema
	if err := db.AutoMigrate(&st860_medicine_master{}); err != nil {
		log.Println("Database migration error:", err)
		resp.Status = "E"
		resp.ErrMessage = "Error: SASTD02 " + err.Error()
		return resp
	}

	// Set creation date and insert master record
	masterRec.Created_Date = time.Now()
	res := db.Table("st860_medicine_master").Create(&masterRec)
	if res.Error != nil {
		log.Println("Error inserting master record:", res.Error)
		resp.Status = "E"
		resp.ErrMessage = "Error: SASTD03 " + res.Error.Error()
		return resp
	}
	var m_id int64
	res2 := db.Table("st860_medicine_master").Select("id").Where("medicine_name=? and brand=?", masterRec.Medicine_Name, masterRec.Brand).Scan(&m_id)
	if res2.Error != nil {
		log.Println("Error retriving master record:", res2.Error)
		resp.Status = "E"
		resp.ErrMessage = "Error: SASTD03 " + res2.Error.Error()
		return resp
	}
	// Set stock record fields and insert stock record
	stockRec.Medicine_Name = masterRec.Medicine_Name
	stockRec.Created_By = masterRec.Created_By
	stockRec.Created_Date = masterRec.Created_Date
	stockRec.M_Id = m_id
	res1 := db.Table("st860_medicine_stock").Create(&stockRec)
	if res1.Error != nil {
		log.Println("Error inserting stock record:", res1.Error)
		resp.Status = "E"
		resp.ErrMessage = "Error: SASTD04 " + res1.Error.Error()
		return resp
	}

	log.Println("Records inserted successfully")
	return resp
}
