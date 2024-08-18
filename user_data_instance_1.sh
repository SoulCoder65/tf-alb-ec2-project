#!/bin/bash
# Update packages
yum update -y

# Install Apache
yum install -y httpd

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
yum install -y aws-cli

# Download the images from S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the new content
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Akshay Saxena's Portfolio</title>
  <style>
    /* Add animation and styling for the text */
    @keyframes colorChange {
      0% { color: orange; }
      50% { color: purple; }
      100% { color: teal; }
    }
    h1 {
      animation: colorChange 2s infinite;
    }
  </style>
</head>
<body>
  <h1>Welcome to Akshay Saxena's Portfolio Instance 1</h1>
  <h2>Instance ID: <span style="color:blue">$INSTANCE_ID</span></h2>
  <p>Building and Deploying with Terraform!</p>
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start httpd
systemctl enable httpd
