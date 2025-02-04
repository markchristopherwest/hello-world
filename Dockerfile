
# Use the official Golang image as the base image
FROM golang:1.23-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files
COPY go.mod go.sum ./

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

# Expose the port on which your app runs
EXPOSE 8080

# Define the command to run your application
CMD ["./myapp"]