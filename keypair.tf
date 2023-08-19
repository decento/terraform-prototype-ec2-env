
// we create an ssh keypair to connect with the bastion
resource "tls_private_key" "acloudkey" {
    algorithm ="RSA"
}

resource "local_file" "acloudkey" {
    content = tls_private_key.acloudkey.private_key_pem
    filename = "${path.module}/acloud.pem"
    file_permission = "0400"
}

resource "aws_key_pair" "acloudkey" {
    key_name = "acloud"
    public_key = tls_private_key.acloudkey.public_key_openssh
}
