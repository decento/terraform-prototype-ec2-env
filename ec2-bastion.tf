// bastion instance
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.acloudkey.key_name
  tags = {
    Name = "bastion01"
  }
  subnet_id = aws_subnet.public1a.id
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]
  user_data = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install ansible2 vim postgresql14 python3.8
  EOT
}

resource "aws_security_group" "bastion_sg" {
  name        = "allow_bastion"
  description = "Allow Bastion"
  vpc_id      = aws_vpc.main.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
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
    Name = "allow_bastion"
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}