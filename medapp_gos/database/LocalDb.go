package database

import (
	// Import the SQL package for database operations
	// Import the fmt package for formatting strings
	"log" // Import the log package for logging messages

	"gorm.io/driver/mysql"
	"gorm.io/gorm" // Import the MySQL driver package (the underscore means it's imported solely for its side effects)
)

// Purpose of the Code

// The LocalDBConnect function is responsible for establishing a connection to a local MySQL database. It uses the Go SQL package along with the MySQL driver to connect to the database using specified credentials and connection details. The function logs the process of connecting to the database and handles any errors that occur during the connection attempt.
// Request and Response
// Request:

//     Input: The function does not take any input parameters from an external request. Instead, it internally constructs the connection string using hardcoded values for the database username, password, host, port, and database name.

// Response:

//     Output:
//         Database Handle (*sql.DB): A database handle that allows interaction with the database if the connection is successful.
//         Error (error): An error value that will be non-nil if there is an issue with the connection process.

// LocalDBConnect establishes a connection to the local MySQL database and returns the database handle and any error encountered.
func LocalDBConnect() (*gorm.DB, error) {
	dsn := "ST860:000ST8601@tcp(192.168.2.5:3306)/training?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
		return nil, err
	}

	return db, nil
}
