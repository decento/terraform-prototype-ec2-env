# terraform-prototype-ec2-env
A exploratory env with the following,
* An nginx web farm behind an elb
* Postgres DB on EC2
* A bastion with an associated ssh keypair.

All instances run using t2.micro.

Meant to be used as a exploratory playground in a lab/test AWS account.
Do not run this on production AWS accounts!!

# setup
```bash
aws configure  # double check you have your lab/test aws account configured, not production!!

terraform init
terrform plan
terraform apply
terraform output  # this will give you the public/private ips of all instances

# use ssh agent for bastion, so you can hop to other instances
BASTION_PUBLIC_IP=$(terraform output -raw bastion_public_ip)
eval `ssh-agent`
ssh-add acloud.pem
ssh -A ec2-user@${BASTION_PUBLIC_IP}  
```

# teardown
```bash
# simply
terraform destroy
```
