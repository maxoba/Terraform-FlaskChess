

resource "aws_instance" "FlaskChess-1" {
  ami           = "ami-05d38da78ce859165" # Replace with a valid AMI ID
  instance_type = var.my_instance         # Correct reference to the variable

  key_name  = var.my_key
  user_data = file("app.sh")

  tags = {
    Name = "FlaskChess-1"
  }
}


resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}