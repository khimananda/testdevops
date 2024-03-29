resource "aws_instance" "web_server"{
    ami = data.aws_ami.ubuntu.id
    disable_api_termination = false
    instance_type = "t2.micro" 
    root_block_device {
        volume_size = "20"
        delete_on_termination = true
    }
    subnet_id = "subnet-0f57068e078f698aa"
    security_groups = ["sg-0021696abcb9be08c"]
    

    lifecycle {
        ignore_changes=[
            security_groups
            ]
    }

    key_name = "khimananda"
  
}