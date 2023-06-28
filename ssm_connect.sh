#!/bin/bash
# Script per connettersi a un'istanza AWS tramite Session Manager

# ID and Profile
INSTANCE_ID=$1
PROFILE_NAME=$2

# Check ID EC2
if [[ -z "$INSTANCE_ID" ]]; then
    echo "Provide EC2 istance ID"
    exit 1
fi

# Check profile specified
if [[ -z "$PROFILE_NAME" ]]; then
    echo "Provide onelogin cli Profile."
    exit 1
fi


# Connect istance
aws ssm start-session --target $INSTANCE_ID --region eu-west-1 --profile $PROFILE_NAME
