// the nginx web instances
resource "aws_instance" "web" {
  for_each      = toset(["webserver01", "webserver02", "webserver03"])
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.acloudkey.key_name
  tags = {
    Name = each.key
  }
  subnet_id = aws_subnet.private1a.id
  vpc_security_group_ids = [
    aws_security_group.allow_web.id
  ]
  user_data = <<-EOT
    #!/bin/bash
    # install nginx
    sudo yum update -y
    sudo amazon-linux-extras install nginx1
    echo "<html><body><h1>Hello from NGINX ${each.key} </h1></body></html>" >/usr/share/nginx/html/index.html
    # make sure nginx is started
    sudo service nginx start
  EOT
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "SSH From Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  ingress {
    description = "Web From Public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
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

output "web_private_ip" {
  value = [
    for i in aws_instance.web : i.private_ip
  ]
}