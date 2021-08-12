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

# resource "aws_instance" "zookeeper" {
#   count=3
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#   security_groups = ["sg-0e32fdd92ee8efd6e","sg-0879eccc07cbce315"]
#   subnet_id = "subnet-0205d7f96edf8370d"
#   key_name  = "khimananda"
#  user_data          = templatefile("./templates/zookeeper_user_data.sh", {
#     SERVICE_NAME = "zookeeper.service"
#     APACHE_ZOOKEEPER_version= "3.4.13"
#     DATA_DIR="/var/lib/zookeeper"
#     myid = count.index + 1
#   })
#   tags = {
#     Name = "zookeeper-test-${count.index}"
#     owner = "khimananda.oli@itonics.de"
#   }
# }

# resource "aws_instance" "solr" {
#   count=1
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#   security_groups = ["sg-0e32fdd92ee8efd6e"]
#   subnet_id = "subnet-0205d7f96edf8370d"
#   key_name  = "khimananda"
#  user_data          = templatefile("./templates/solr_user_data.sh", {
#     SERVICE_NAME = "solr.service"
#     DATA_DIR="/var/solr"
#   })
#   tags = {
#     Name = "solr-test"
#     owner = "khimananda.oli@itonics.de"
#     description="testing solr using terraform"
#   }
# }


# resource "aws_route53_record" "record" {
#   count   = 3
#   zone_id = "Z07541393826CKY1F82U6"
#   name    = "zk${count.index + 1}.itonics.services"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_instance.zookeeper[count.index].private_dns]
# }
