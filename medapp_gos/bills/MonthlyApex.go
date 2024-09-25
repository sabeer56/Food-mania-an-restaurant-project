package bills

import (
	d "medapp_gos/database"
)

func MonthlySale() (MonthlyResp, error) {
	var resp MonthlyResp

	// Connect to the database
	db, err := d.LocalDBConnect()

	DB, _ := db.DB()
	if err != nil {
		resp.Status = "E"
		resp.Errmsg = err.Error()
		return resp, err
	}
	defer DB.Close()
	var bills []MonthlyStruct
	res := db.Table("st860_bill_master m").Select("MONTHNAME(m.bill_date) AS month_name,IFNULL(SUM(m.bill_amount), 0) AS total_bill_amount").Where(" YEAR(m.bill_date) = YEAR(CURDATE())").Group(" DATE_FORMAT(m.bill_date, '%Y-%m')").Scan(&bills)

	if res.Error != nil {
		resp.Status = "E"
		resp.Errmsg = res.Error.Error()
		return resp, err
	}
	resp.MonthArr = bills
	var daily []dailyStruct

	res1 := db.Table("st860_bill_master").
		Select("DAYNAME(bill_date) AS day_name, IFNULL(SUM(bill_amount), 0) AS total_bill_amount").
		Where("YEARWEEK(bill_date, 1) = YEARWEEK(CURDATE(), 1)").
		Group("DAYOFWEEK(bill_date)").
		Order("DAYOFWEEK(bill_date)").
		Scan(&daily)

	if res1.Error != nil {
		resp.Status = "E"
		resp.Errmsg = res1.Error.Error()
		return resp, res1.Error
	}
	resp.DayArr = daily

	// Return the response struct
	return resp, nil
}
