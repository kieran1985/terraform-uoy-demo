// TEST BUCKET 1
resource "aws_s3_bucket" "test-bucket" {
  bucket = "test-interview-bucket-s9d3d5x9"
  tags = {
    name = "test-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "test-bucket-ownership" {
  bucket = aws_s3_bucket.test-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "test-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.test-bucket-ownership]
  
  bucket = aws_s3_bucket.test-bucket.id
  acl    = "private"
}
