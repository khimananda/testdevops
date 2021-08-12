resource "aws_instance" "web_server"{
    ami = "ami-05f7491af5eef733a"
    disable_api_termination = false
    instance_type = "t2.micro" 
    root_block_device {
        volume_size = "20"
        delete_on_termination = true
    }
    subnet_id = "subnet-0205d7f96edf8370d"
    security_groups = ["sg-044102dbdf041d9cc"]

    lifecycle {
        ignore_changes=[
            security_groups
            ]
    }

    key_name = "khimananda"
  
}