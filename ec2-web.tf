// the nginx web instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.acloudkey.key_name
  tags = {
    Name = "webserver01"
  }
  subnet_id = aws_subnet.public1a.id
  vpc_security_group_ids = [
    aws_security_group.allow_web.id
  ]
  user_data = <<-EOT
    #!/bin/bash
    # install nginx
    sudo yum update -y
    sudo amazon-linux-extras install nginx1

    # make sure nginx is started
    sudo service nginx start
  EOT
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound"
  vpc_id      = aws_vpc.main.id
    ingress {
        description      = "SSH From Bastion"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        security_groups = [
            aws_security_group.bastion_sg.id
        ]
    }
  ingress {
    description      = "Web80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Web443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_web"
  }
}


output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}