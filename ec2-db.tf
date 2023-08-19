// the postgres database instance
resource "aws_instance" "db" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.acloudkey.key_name
  tags = {
    Name = "dbserver01"
  }
  subnet_id = aws_subnet.private1a.id
  vpc_security_group_ids = [
    aws_security_group.allow_db.id
  ]
  user_data = <<-EOT
  #!/bin/bash
  sudo tee /etc/yum.repos.d/pgdg.repo<<EOF
  [pgdg14]
  name=PostgreSQL 14 for RHEL/CentOS 7 - x86_64
  baseurl=https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-7-x86_64
  enabled=1
  gpgcheck=0
  EOF
  sudo yum update -y
  sudo yum install -y postgresql14 postgresql14-server
  sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
  sudo systemctl enable postgresql-14
  sudo systemctl start postgresql-14
  sleep 15
  sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
  echo "listen_addresses = '*'" |sudo tee -a /var/lib/pgsql/14/data/postgresql.conf
  echo "host    all             all              0.0.0.0/0                       md5" |sudo tee -a /var/lib/pgsql/14/data/pg_hba.conf
  sudo systemctl restart postgresql-14
  EOT
}


resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow DB"
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
    description      = "Postgres From Bastion"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [
        aws_security_group.bastion_sg.id
    ]
}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_db"
  }
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}