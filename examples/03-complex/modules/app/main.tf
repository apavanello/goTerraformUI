variable "db_endpoint" {
  type = string
}

resource "aws_instance" "app" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Connecting to ${var.db_endpoint}"
              EOF
}

output "app_id" {
  value = aws_instance.app.id
}
