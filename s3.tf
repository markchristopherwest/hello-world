resource "aws_s3_bucket" "mongo" {
  bucket = random_pet.example.id
  # acl = "public-read"
  tags = {
    Name        = random_pet.example.id
    Environment = "Dev"
  }
}