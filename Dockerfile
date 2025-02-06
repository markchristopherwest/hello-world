# Create arguments for the DB target

# Use the official Golang image as the base image
FROM golang:1.23-alpine AS build

ENV DB_HOST="localhost"
ENV DB_PORT=27017
ENV DB_NAME="dude"
ENV DB_PASS="dude"
ENV DB_USER="localhost"

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files
COPY go.mod go.sum wizexercise.txt ./
COPY mongo-setup.js /docker-entrypoint-initdb.d/mongo-init.js:

# Download the Go module dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o myapp ./

# Use a smaller base image for the final image
FROM alpine:latest

# Copy the built binary from the previous stage
COPY --from=build /app/myapp /myapp
COPY --from=build /app/wizexercise.txt /wizexercise.txt

# Expose the port on which your app runs
EXPOSE 3000

# Define the command to run your application
CMD ["./myapp"]