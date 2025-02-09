resource "aws_s3_bucket" "mongo" {
  bucket = random_pet.example.id
  # acl = "public-read"
  tags = {
    Name        = random_pet.example.id
    Environment = "Dev"
  }
}
# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = aws_s3_bucket.mongo.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }