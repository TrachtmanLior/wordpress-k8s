provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "k3s_node" {
  ami           = "ami-0c2b8ca1dad447f8a"  # Amazon Linux 2 (replace as needed)
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name

  user_data = file("install_k3s.sh")

  tags = {
    Name = "k3s-ec2-node"
  }
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Password123!"  # for demo only – use secrets in real world
  db_name              = "wordpress"
  skip_final_snapshot  = true
}
