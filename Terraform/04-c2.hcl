variable "ami_id" {
  type    = string
  default = "ami-05134c8ef96964280" # Valeur par défaut

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"
}