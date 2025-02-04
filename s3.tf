resource "aws_s3_bucket" "mongo" {
  bucket = random_pet.example.id

  tags = {
    Name        = random_pet.example.id
    Environment = "Dev"
  }
}