#Create EC2 Instance for Jenkins, Docker, and SonarQube
resource "aws_instance" "web" {
  ami                    = "ami-0287a05f0ef0e9d9a"      # Amazon Machine Image (AMI) ID for the instance; change based on the region I chosen ap-south.
  instance_type          = "t2.large"                  # Instance type defining compute capacity; here, t2.large is used.
  key_name               = "Linux-VM-Key2411"             # Key pair for SSH access; replace with your key pair.
  vpc_security_group_ids = [aws_security_group.Jenkins-VM-SG.id] # Security group ID; provides firewall rules for the instance.
  user_data              = templatefile("./install.sh", {}) # Shell script (install.sh) executed when the instance is provisioned.

  tags = {
    Name = "Jenkins-SonarQube"                         # Tags provide metadata; here, it names the instance.
  }

  root_block_device {
    volume_size = 40                                   # Specifies root volume size in GB for the instance.
  }
}

resource "aws_security_group" "Jenkins-VM-SG" {
  name        = "Jenkins-VM-SG"                        # Name of the security group.
  description = "Allow TLS inbound traffic"           # Description of the security group.

  # Ingress rules define incoming traffic.
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {    # Loop through required ports (SSH, HTTP, HTTPS, Jenkins, SonarQube).
      description      = "inbound rules"              # Description for the rule.
      from_port        = port                         # Starting port of the range.
      to_port          = port                         # Ending port of the range.
      protocol         = "tcp"                        # Protocol used for traffic.
      cidr_blocks      = ["0.0.0.0/0"]                # Allows traffic from any IP (use cautiously).
      ipv6_cidr_blocks = []                           # No IPv6 traffic allowed.
      prefix_list_ids  = []                           # No prefix lists used.
      security_groups  = []                           # No reference to other security groups.
      self             = false                        # Prevent self-referencing.
    }
  ]

  # Egress rules define outgoing traffic.
  egress {
    from_port   = 0                                   # Starting port for egress.
    to_port     = 0                                   # Ending port for egress.
    protocol    = "-1"                                # Allow all protocols.
    cidr_blocks = ["0.0.0.0/0"]                       # Allow traffic to any IP. Note: Never set in Production environment!!
  }

  tags = {
    Name = "Jenkins-VM-SG"                            # Metadata for the security group.
  }
}
