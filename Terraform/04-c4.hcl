resource "aws_instance" "example" {
  ami           = "ami-05134c8ef96964280"
  instance_type = "t2.micro"
  key_name      = "demo-key"  # Suppression de ".pem"
}