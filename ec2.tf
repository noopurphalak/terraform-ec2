resource "aws_instance" "webserver" {
    ami = var.ami
    instance_type = var.instance_type
    tags = {
        Name = "webserver"
        Description = "An Nginx Web Server on Ubuntu"
    }
    user_data = file("install_details.sh")
    key_name = aws_key_pair.web.id
    vpc_security_group_ids = [aws_security_group.ssh-http-access.id]
}

resource "tls_private_key" "ec2-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web" {
    public_key = trimspace(tls_private_key.ec2-key.public_key_openssh)
}

resource "aws_security_group" "ssh-http-access" {
    name = "ssh-http-access"
    description = "SSH and HTTP access to webserver"

    dynamic "ingress" {
        for_each = var.ingress_rules
        content {
            from_port = ingress.value["from_port"]
            to_port = ingress.value["to_port"]
            protocol = ingress.value["protocol"]
            cidr_blocks = ingress.value["cidr_blocks"]
        }
    }

    dynamic "egress" {
        for_each = var.egress_rules
        content {
            from_port = egress.value["from_port"]
            to_port = egress.value["to_port"]
            protocol = egress.value["protocol"]
            cidr_blocks = egress.value["cidr_blocks"]
        }
    }
}

output privatekey {
    value = tls_private_key.ec2-key.private_key_pem
    sensitive = true
}

output publicip {
    value = aws_instance.webserver.public_ip
    sensitive = true
}