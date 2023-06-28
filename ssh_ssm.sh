#!/usr/bin/env sh
######## Source ################################################################
#
# https://github.com/qoomon/aws-ssm-ec2-proxy-command
#
######## Usage #################################################################
# https://github.com/qoomon/aws-ssm-ec2-proxy-command/blob/master/README.md
#
# Install Proxy Command
#   - Move this script to ~/.ssh/aws-ssm-ec2-proxy-command.sh
#   - Ensure it is executable (chmod +x ~/.ssh/aws-ssm-ec2-proxy-command.sh)
#
# Add following SSH Config Entry to ~/.ssh/config
#   host i-* mi-*
#     IdentityFile ~/.ssh/id_rsa
#     ProxyCommand ~/.ssh/aws-ssm-ec2-proxy-command.sh %h %r %p ~/.ssh/id_rsa.pub
#     StrictHostKeyChecking no
#
# Ensure SSM Permissions for Target Instance Profile
#   https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html
#
# Open SSH Connection
#   ssh <INSTANCE_USER>@<INSTANCE_ID>
#   
#   Ensure AWS CLI environment variables are set properly
#   e.g. AWS_PROFILE='default' ssh ec2-user@i-xxxxxxxxxxxxxxxx
#
################################################################################
set -eu

export AWS_DEFAULT_REGION='eu-west-1'

ec2_instance_id="$1"
ssh_user="$2"
ssh_public_key_path="$3"
aws_profile="$4"

aws_command="aws"
if [[ -n "$aws_profile" ]]; then
    aws_command="aws --profile $aws_profile"
fi

instance_availability_zone="$($aws_command ec2 describe-instances \
    --instance-id "$ec2_instance_id" \
    --query "Reservations[0].Instances[0].Placement.AvailabilityZone" \
    --output text)"

>/dev/stderr echo "Add public key ${ssh_public_key_path} for ${ssh_user} at instance ${ec2_instance_id} for 60 seconds"
$aws_command ec2-instance-connect send-ssh-public-key  \
  --instance-id "$ec2_instance_id" \
  --instance-os-user "$ssh_user" \
  --ssh-public-key "file://$ssh_public_key_path" \
  --availability-zone "$instance_availability_zone"

>/dev/stderr echo "Start ssm session to instance ${ec2_instance_id}"
$aws_command ssm start-session \
  --target "${ec2_instance_id}" \
  --document-name 'AWS-StartSSHSession'
