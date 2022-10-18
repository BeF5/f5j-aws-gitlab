data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-*-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2-gitlab_sg" {
  name   = "ec2-gitlab_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-gitlab_sg"
    Lab  = "Containers"
  }
}

resource "aws_instance" "ec2-gitlab" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.instance_type
  count                  = var.ec2-gitlab_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2-gitlab_sg.id]
  subnet_id              = var.vpc_subnet[0]

  root_block_device {
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
#    Name = "${count.index == 0 ? "ec2-gitlab-master1" : "ec2-gitlab-node${count.index}"}"
    Name = "ec2-gitlab-node${count.index + 1 }"
    Lab  = "Containers"
  }
}

# write out ec2-gitlab inventory
data "template_file" "inventory" {
  template = <<EOF
[all]
%{ for instance in aws_instance.ec2-gitlab ~}
${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}
%{ endfor ~}

[masters]
%{ for instance in aws_instance.ec2-gitlab ~}
%{ if substr(instance.tags.Name, 5, 6) == "master" }${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}%{ endif }
%{ endfor ~}

[nodes]
%{ for instance in aws_instance.ec2-gitlab ~}
%{ if substr(instance.tags.Name, 5, 4) == "node" }${instance.tags.Name} ansible_host=${instance.public_ip} private_ip=${instance.private_ip}%{ endif }
%{ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
EOF

}


##------ Deploy Juice Shop With ASM Pattern -----
resource "local_file" "save_inventory" {
  depends_on = [data.template_file.inventory]
  content = data.template_file.inventory.rendered
  filename = "./ec2-gitlab/ansible/inventory.ini"
}

#----- Run Ansible Playbook -----
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    working_dir = "./ec2-gitlab/ansible/"

    command = <<EOF
    aws ec2 wait instance-status-ok --region ${var.aws_region} --profile ${var.aws_profile} --instance-ids ${join(" ", aws_instance.ec2-gitlab.*.id)}
    sudo apt update
    # sudo apt install software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -y

    ansible-playbook ./playbooks/deploy-ec2-gitlab.yaml --private-key ../../id_rsa_ec2-gitlab
    EOF
  }
}
#-------- ec2-gitlab output --------

output "public_ip" {
  value = formatlist(
  "%s = %s",
  aws_instance.ec2-gitlab.*.tags.Name,
  aws_instance.ec2-gitlab.*.public_ip
  )
}

output "private_ip" {
#  value = formatlist(
#  "%s = %s",
#  aws_instance.ec2-gitlab.*.tags.Name,
#  aws_instance.ec2-gitlab.*.private_ip
#  )
   value = aws_instance.ec2-gitlab.*.private_ip
}

