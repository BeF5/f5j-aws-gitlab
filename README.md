# deploy-ec2-gitlab

## Objective
## How to use
- An active AWS Account, with proper IAM configuration.
- Set appripriciate Linux CLI Environment to deploy.
    1. set aws api environment parameter

        AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

    1. Specify or create ssh key
    
        CREATE SAMPLE:ssh-keygen -t rsa -f id_rsa_ec2-gitlab

    1. modify terraform.tfvars validly

        vi terraform.tfvars
          aws_region , public_key_path , private_key_path

- how to deploy
  1. git clone 'here'
  2. terraform init , terraform plan, terraform apply
- how to look login information after deploy
  - terraform refresh
  - terraform output
- how to connect insntance with ssh
  - ssh <IP> -l ubuntu -i <ssh key created above>
- how to delete
  - terraform destroy

## Commnet
- After deploy gitlab, it takes about 5 minutes until status become healthy.

```
CONTAINER ID   IMAGE                     COMMAND             CREATED         STATUS      PORTS    NAMES
6e06c1556a88   gitlab/gitlab-ce:latest   "/assets/wrapper"   5 minutes ago   Up 5 minutes (healthy)   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp, 0.0.0.0:4567->4567/tcp, :::4567->4567/tcp, 0.0.0.0:5000->5000/tcp, :::5000->5000/tcp, 0.0.0.0:30022->22/tcp, :::30022->22/tcp   gitlab
```

- To check gitlab default password, please type this command.

```
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

- Security groups src IP is limited in Global IP of the hosts that runs terraform. Please modify src IP as you hope.
