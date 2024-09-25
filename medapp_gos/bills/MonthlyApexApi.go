package bills

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type dailyStruct struct {
	Daily float64 `json:"daily" gorm:"column:total_bill_amount"`
	Day   string  `json:"day" gorm:"column:day_name"`
}
type MonthlyStruct struct {
	MonthlySale float64 `json:"monthlysale" gorm:"column:total_bill_amount"`
	Month       string  `json:"month" gorm:"column:month_name;"`
}
type MonthlyResp struct {
	MonthArr []MonthlyStruct `json:"montharr"`
	DayArr   []dailyStruct   `json:"dayarr"`
	Status   string          `json:"status"`
	Errmsg   string          `json:"errmsg"`
}

func MonthlyApi(w http.ResponseWriter, r *http.Request) {
	(w).Header().Set("Access-Control-Allow-Origin", "*")
	(w).Header().Set("Access-Control-Allow-Methods", "GET,OPTIONS")
	(w).Header().Set("Access-Control-Allow-Headers", "USER,Accept,Content-Type,Content-Length,Accept-Encoding,X-CSRF-Token,Authorization")
	log.Println("getData(+)")
	if r.Method == "GET" {
		var resp MonthlyResp
		resp.Status = "S"
		resp, err := MonthlySale()
		if err != nil {
			log.Println(err)
			resp.Errmsg = err.Error()
			resp.Status = "E"
		} else {
			data, err := json.Marshal(resp)
			if err != nil {
				fmt.Fprintf(w, "error taking data LHA00"+err.Error())
			} else {
				fmt.Fprintf(w, string(data))
			}
			log.Println("getdata(-)")
		}

	}
}
