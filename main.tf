data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "zookeeper" {
  count=1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  security_groups = ["sg-0e32fdd92ee8efd6e"]
  subnet_id = "subnet-0205d7f96edf8370d"
  key_name  = "khimananda"
 user_data          = templatefile("./templates/zookeeper_user_data.sh", {
    SERVICE_NAME = "zookeeper.service"
    APACHE_ZOOKEEPER_version= "3.4.13"
    DATA_DIR="/var/lib/zookeeper"
    myid = count.index + 1
  })
  tags = {
    Name = "zookeeper-test"
    owner = "khimananda.oli@itonics.de"
  }
}
