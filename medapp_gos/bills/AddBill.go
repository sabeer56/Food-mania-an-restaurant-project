package bills

import (
	"encoding/json"
	"io"
	"log"
	d "medapp_gos/database"
	"net/http"
	"time"
)

type StockItem struct {
	Quantity int `gorm:"column:quantity"`
	MID      int `gorm:"column:m_id"`
}

// st860_bill_master_details represents the structure of a bill record.
type Bill_master_details struct {
	Id                int         `gorm:"primaryKey"`
	Bill_No           string      `json:"Bill_No" gorm:"column:Bill_No"`             // Bill number field from the JSON request
	Medicine_Name     string      `json:"Medicine_Name" gorm:"column:medicine_name"` // Medicine name field from the JSON request
	Brand             string      `json:"Brand" gorm:"column:brand"`
	Quantity          int         `json:"Quantity" gorm:"column:quantity"`   // Quantity field from the JSON request
	UnitPrice         int         `json:"UnitPrice" gorm:"column:unitprice"` // Unit price field from the JSON request
	Netprice          float64     `json:"netprice" gorm:"column:netprice"`
	Created_By        string      `json:"Created_By" gorm:"column:created_by"`
	Created_Date      time.Time   `json:"Created_Date" gorm:"column:created_date"`
	Updated_By        string      `json:"Updated_By" gorm:"column:updated_by"`
	Updated_Date      time.Time   `json:"Updated_Date" gorm:"column:updated_date"`
	St860_bill_master Bill_master `gorm:"foreignKey:Bill_No"`
}
type Bill_master_details1 struct {
	Id            int    `gorm:"primaryKey"`
	Bill_No       string `json:"Bill_No" gorm:"column:Bill_No"`             // Bill number field from the JSON request
	Medicine_Name string `json:"Medicine_Name" gorm:"column:medicine_name"` // Medicine name field from the JSON request

	Quantity          int         `json:"Quantity" gorm:"column:quantity"`   // Quantity field from the JSON request
	UnitPrice         int         `json:"UnitPrice" gorm:"column:unitprice"` // Unit price field from the JSON request
	Netprice          float64     `json:"netprice" gorm:"column:netprice"`
	Created_By        string      `json:"Created_By" gorm:"column:created_by"`
	Created_Date      time.Time   `json:"Created_Date" gorm:"column:created_date"`
	Updated_By        string      `json:"Updated_By" gorm:"column:updated_by"`
	Updated_Date      time.Time   `json:"Updated_Date" gorm:"column:updated_date"`
	St860_bill_master Bill_master `gorm:"foreignKey:Bill_No"`
}

type Bill_master struct {
	Id           int       `gorm:"primaryKey"`
	Bill_No      string    `json:"Bill_No" gorm:"column:bill_no"`
	Bill_Date    time.Time `json:"Bill_Date" gorm:"column:bill_date;type:date"`
	Bill_Amount  int       `json:"UnitPrice" gorm:"column:bill_amount"`
	Gst          float64   `json:"GST" gorm:"column:gst"`
	Netprice     float64   `json:"netprice" gorm:"column:netprice"`
	Login_Id     string    `json:"login_id" gorm:"column:Login_id"`
	Created_By   string    `json:"Created_By" gorm:"column:created_by"`
	Created_Date time.Time `json:"Created_Date" gorm:"column:created_date;type:date"`
	Updated_By   string    `json:"Updated_By" gorm:"column:updated_by"`
	Updated_Date time.Time `json:"Updated_Date" gorm:"column:updated_date"`
}

func (Bill_master) TableName() string {
	return "St860_bill_master"
}
func (Bill_master_details) TableName1() string {
	return "St860_bill_master_details"
}

// GBillResponse represents the structure of the response for bill operations.
type GBillResponse struct {
	Status string `json:"status"` // Status of the operation (Success/Failure)
	ErrMsg string `json:"errmsg"` // Error message if the operation fails
}

// Error codes for bill operations
const (
	ErrReadBody          = "Error: BAB01"
	ErrUnmarshalBody     = "Error: BAB02"
	ErrDBConnect         = "Error: BAB03"
	ErrStockQuery        = "Error: BAB04"
	ErrInsufficientStock = "Error: BAB05 Insufficient stock"
	ErrInsertBill        = "Error: BAB06"
	ErrUpdateStock       = "Error: BAB07"
)

// sendResponse sends a response in JSON format

// AddBills handles HTTP requests to add bills.
// AddBills handles HTTP requests to add bills.
func AddBills(pw http.ResponseWriter, pr *http.Request) {
	// Set headers to handle CORS and specify the content type
	pw.Header().Set("Access-Control-Allow-Origin", "*")
	pw.Header().Set("Access-Control-Allow-Credentials", "true")
	pw.Header().Set("Access-Control-Allow-Methods", "POST,OPTIONS")
	pw.Header().Set("Content-Type", "application/json")
	pw.Header().Set("Access-Control-Allow-Headers", "Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")

	// Handle preflight OPTIONS request (CORS preflight)
	if pr.Method == "OPTIONS" {
		pw.WriteHeader(http.StatusOK)
		return
	}

	if pr.Method == "POST" {
		var lbillArr []Bill_master_details
		var lresp GBillResponse
		var billNo1 string
		var netPrice float64
		var gstMain float64
		var billAmount int
		var created_by string

		// Read the body of the request
		lbody, lerr := io.ReadAll(pr.Body)
		if lerr != nil {
			lresp.Status = "E"
			lresp.ErrMsg = ErrReadBody + " " + lerr.Error()
			sendResponse(pw, lresp)
			return
		}

		log.Printf("Received body: %s", lbody)

		// Unmarshal the JSON body into the slice of bills
		lerr = json.Unmarshal(lbody, &lbillArr)
		if lerr != nil {
			lresp.Status = "E"
			lresp.ErrMsg = ErrUnmarshalBody + " " + lerr.Error()
			sendResponse(pw, lresp)
			return
		}

		// Connect to the database
		db, lerr := d.LocalDBConnect()
		DB, _ := db.DB()
		if lerr != nil {
			lresp.Status = "E"
			lresp.ErrMsg = ErrDBConnect + " " + lerr.Error()
			sendResponse(pw, lresp)
			return
		}
		defer DB.Close()
		// Process each bill
		for _, lbillRec := range lbillArr {
			var stockVal StockItem
			res := db.Table("st860_medicine_stock s").
				Select("s.quantity, s.m_id").
				Joins("JOIN st860_medicine_master m ON m.id = s.m_id").
				Where("s.medicine_name = ? AND m.brand = ?", lbillRec.Medicine_Name, lbillRec.Brand).
				Scan(&stockVal)
			if res.Error != nil {
				lresp.Status = "E"
				lresp.ErrMsg = ErrStockQuery + " " + res.Error.Error()
				sendResponse(pw, lresp)
				return
			}

			if stockVal.Quantity < lbillRec.Quantity {
				lresp.Status = "E"
				lresp.ErrMsg = ErrInsufficientStock
				sendResponse(pw, lresp)
				return
			}
			billNo1 = lbillRec.Bill_No
			// Compute GST and Total Price
			gstMain = gstMain + (float64(lbillRec.UnitPrice) * 0.18)
			billAmount = billAmount + int(float64(lbillRec.UnitPrice))
			netPrice = float64(gstMain) + float64(billAmount) + netPrice
			created_by = lbillRec.Created_By
			res1 := db.Table("St860_medicine_stock").Where("medicine_name = ? and m_id=?", lbillRec.Medicine_Name, stockVal.MID).Update("quantity", stockVal.Quantity-lbillRec.Quantity)
			if res1.Error != nil {
				lresp.Status = "E"
				lresp.ErrMsg = ErrUpdateStock + " " + res1.Error.Error()
				sendResponse(pw, lresp)
				return
			}

		}
		billMaster := Bill_master{
			Bill_No:      billNo1,
			Bill_Date:    time.Now(),
			Bill_Amount:  billAmount,
			Gst:          gstMain,
			Netprice:     netPrice,
			Login_Id:     created_by,
			Created_By:   created_by,
			Created_Date: time.Now(),}

		res := db.Create(&billMaster)
		if res.Error != nil {
			lresp.Status = "E"
			lresp.ErrMsg = ErrInsertBill + " " + res.Error.Error()
			sendResponse(pw, lresp)
			return
		}

		lresp.Status = "S"
		sendResponse(pw, lresp)
		log.Println("InsertData(-)")
	} else {
		http.Error(pw, "Method not allowed", http.StatusMethodNotAllowed)
	}
}
