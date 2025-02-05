package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

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
		fmt.Println("Environment variable DB_HOST not set.")
	} else {
		fmt.Println("Value of DB_PORT:", dbPort)
	}

	username := "dude"
	password := "dude"
	database := "admin"

	connectionString := fmt.Sprintf("mongodb://%s:%s@%s:%s/%s", username, password, dbHost, dbPort, database)

	fmt.Println(connectionString)

	// Use the connection string to create a client
	client, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(connectionString))
	if err != nil {
		log.Fatal(err)
	}

	// Check the connection
	err = client.Ping(context.TODO(), nil)
	if err != nil {

		fmt.Println(err)
		log.Fatal(err)
	}

	fmt.Println("Connected to MongoDB!")
	log.Println("Connected to MongoDB!")

	// Access a database
	db := client.Database(database)

	// Access a collection
	collection := db.Collection("first")

	// Insert a document
	user := bson.D{{Key: "name", Value: "John"}, {Key: "age", Value: 30}}
	insertResult, err := collection.InsertOne(context.TODO(), user)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Inserted a single document: ", insertResult.InsertedID)

	port := 8080
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Welcome to my Golang web server!\n")

		// Find a document
		var result bson.M
		err = collection.FindOne(context.TODO(), bson.D{{Key: "name", Value: "John"}}).Decode(&result)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Fprintf(w, "Found a single document: %+v\n", result)
	})

	http.HandleFunc("/backup", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Backing that MongoDB to S3 for you!\n")

		// Find a document
		var result bson.M
		err = collection.FindOne(context.TODO(), bson.D{{Key: "name", Value: "John"}}).Decode(&result)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Fprintf(w, "Found a single document: %+v\n", result)
	})
	fmt.Printf("Server is listening on port %s...\n", port)
	log.Printf("Server is listening on port %s...\n", port)

	fmt.Printf("Let's get ready to rumble!")
	http.ListenAndServe(":8080", nil)

	// Disconnect from MongoDB
	err = client.Disconnect(context.TODO())
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Connection to MongoDB closed.")
}
