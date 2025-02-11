provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-05134c8ef96964280"
  instance_type = "t2.micro"

  subnet_id = "subnet-0a1b2c3d4e5f67890" # Ajout de l'ID du sous-réseau
}