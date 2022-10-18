aws_profile = "ec2-gitlab-deploy"
aws_region  = "ap-northeast-1"
#aws_region  = "us-east-2"
vpc_cidr    = "10.1.0.0/16"
env_count   = 2


cidrs = {
  mgmt1     = "10.1.1.0/24"
  external1 = "10.1.2.0/24"
  internal1 = "10.1.3.0/24"
}

key_name            = "ec2-gitlab-deploy-key"
public_key_path     = "./id_rsa_ec2-gitlab.pub"
ec2-gitlab_instance_type  = "t3.medium"
ec2-gitlab_count    = 1

#ec2-gitlab_nodes  = "${module.ec2-gitlab.private_ip}"
