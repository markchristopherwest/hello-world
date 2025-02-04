package main

import (
	"context"
	"fmt"
	"log"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	// Set client options
	clientOptions := options.Client().ApplyURI("mongodb://localhost:27017")

	// Connect to MongoDB
	client, err := mongo.Connect(context.TODO(), clientOptions)
	if err != nil {

		fmt.Println(err)
		log.Fatal(err)

	}

	// Check the connection
	err = client.Ping(context.TODO(), nil)
	if err != nil {

		fmt.Println(err)
		log.Fatal(err)
	}

	fmt.Println("Connected to MongoDB!")

	// Get a handle for the "test" database and "users" collection
	collection := client.Database("test").Collection("users")

	// Insert a document
	user := bson.D{{Key: "name", Value: "John"}, {Key: "age", Value: 30}}
	insertResult, err := collection.InsertOne(context.TODO(), user)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Inserted a single document: ", insertResult.InsertedID)

	// Find a document
	var result bson.M
	err = collection.FindOne(context.TODO(), bson.D{{Key: "name", Value: "John"}}).Decode(&result)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Found a single document: ", result)

	// Disconnect from MongoDB
	err = client.Disconnect(context.TODO())
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Connection to MongoDB closed.")
}
