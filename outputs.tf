# -------root/outputs.tf--------


output "EC2-GitLab_IPs" {
  value = module.ec2-gitlab.public_ip
}



#output "Environment" {
#  value = module.ec2-gitlab.public_ip,
#  value = module.ec2-gitlab.private_ip
#}


# output "Environment" {
#   value = "${
#     map(
#         "BIGIP_Admin_URL", "${module.bigip.public_dns}",
#         "BIIGP_Mgmt_IP", "${module.bigip.public_ip}",
#         "CTFd_IPs", "${module.ec2-gitlab.public_ip}"
#     )
#   }"
# }
