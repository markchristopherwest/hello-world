package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

type Trainer struct {
	Name string
	Age  int
	City string
}
type Record struct {
	Name string
	Age  int
	City string
}

func connectMongoDB(uri, username, password string) (*mongo.Client, error) {
	clientOptions := options.Client().ApplyURI(uri)
	clientOptions.SetAuth(options.Credential{
		Username:      username,
		Password:      password,
		AuthMechanism: "SCRAM-SHA-256",
	})

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to MongoDB: %w", err)
	}

	err = client.Ping(ctx, readpref.Primary())
	if err != nil {
		return nil, fmt.Errorf("failed to ping MongoDB: %w", err)
	}

	return client, nil
}

func main() {

	// Get the value of the environment variable "MY_ENV_VAR"
	dbHost := os.Getenv("DB_HOST")

	// Check if the environment variable exists
	if dbHost == "" {
		fmt.Println("Environment variable DB_HOST not set.")
	} else {
		fmt.Println("Value of DB_HOST:", dbHost)
	}

	// Get the value of the environment variable "MY_ENV_VAR"
	dbPort := os.Getenv("DB_PORT")

	// Check if the environment variable exists
	if dbPort == "" {
		fmt.Println("Environment variable DB_PORT not set.")
	} else {
		fmt.Println("Value of DB_PORT:", dbPort)
	}

	// Get the value of the environment variable "MY_ENV_VAR"
	dbUser := os.Getenv("DB_USER")

	// Check if the environment variable exists
	if dbUser == "" {
		fmt.Println("Environment variable DB_USER not set.")
	} else {
		fmt.Println("Value of DB_USER:", dbUser)
	}

	// Get the value of the environment variable "MY_ENV_VAR"
	dbPass := os.Getenv("DB_PASS")

	// Check if the environment variable exists
	if dbPass == "" {
		fmt.Println("Environment variable DB_PASS not set.")
	} else {
		fmt.Println("Value of DB_PASS:", dbPass)
	}

	// Get the value of the environment variable "MY_ENV_VAR"
	dbName := os.Getenv("DB_NAME")

	// Check if the environment variable exists
	if dbName == "" {
		fmt.Println("Environment variable DB_NAME not set.")
	} else {
		fmt.Println("Value of DB_NAME:", dbName)
	}

	// Replace with your actual connection string, username, and password
	uri := fmt.Sprintf("mongodb://%s:%s", dbHost, dbPort)
	username := "dude"
	password := "changeme"

	client, err := connectMongoDB(uri, username, password)
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err = client.Disconnect(context.TODO()); err != nil {
			panic(err)
		}
	}()

	fmt.Println("Successfully connected to MongoDB!")
	collection := client.Database(dbName).Collection("first")

	// Some dummy data to add to the Database
	ash := Trainer{"Larry", 10, "AWS Town"}
	misty := Trainer{"Moe", 10, "Google City"}
	brock := Trainer{"Curly", 15, "Azure Land"}

	// Insert a single document
	insertResult, err := collection.InsertOne(context.TODO(), ash)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Inserted a single document: ", insertResult.InsertedID)

	// Insert multiple documents
	trainers := []interface{}{misty, brock}

	insertManyResult, err := collection.InsertMany(context.TODO(), trainers)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Inserted multiple documents: ", insertManyResult.InsertedIDs)
	// port := 3000
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Welcome to my Golang web server!\n")

		// Access a specific database and collection
		collection := client.Database(dbName).Collection("first")

		// Find all documents
		cursor, err := collection.Find(context.TODO(), bson.D{})
		if err != nil {
			log.Fatal(err)
		}
		defer func() {
			if err := cursor.Close(context.TODO()); err != nil {
				panic(err)
			}
		}()

		// Iterate through the cursor and decode each document
		var records []Record
		for cursor.Next(context.TODO()) {
			var record Record
			err := cursor.Decode(&record)
			if err != nil {
				log.Fatal(err)
			}
			records = append(records, record)
		}
		if err := cursor.Err(); err != nil {
			log.Fatal(err)
		}

		// Print the retrieved records
		fmt.Println("Retrieved records:")
		for _, record := range records {
			// fmt.Printf("%+v\n", record)
			fmt.Fprintf(w, "%+v\n", record)

		}

	})
	http.ListenAndServe(":3000", nil)

	fmt.Printf("Server is listening on port 3000")

}
