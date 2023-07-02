#!/usr/bin/env bash
# Based on https://gist.github.com/jokeru/e4a25bbd95080cfd00edf1fa67b06996?permalink_comment_id=4606793#gistcomment-4606793
# Added a prompt to select the next action.

GREEN=$'\e\033[0;32m'
BLUE=$'\e\033[1;34m'
RED=$'\e\033[0;31m'
YELLOW=$'\e\033[0;33m'
NC=$'\e\033[0m' # No Color
INDENT='    '

#Regions to delete
REGIONS='us-west-1
us-west-2
us-east-1
us-east-2
ap-south-1
ap-northeast-1
ap-northeast-2
ap-northeast-3
ap-southeast-1
ap-southeast-2
ca-central-1
eu-west-1
eu-west-2
eu-west-3
sa-east-1'

skipRegion=0
echo "Using profile $AWS_PROFILE"

echo
for region in $REGIONS; do
  export AWS_REGION=$region
  echo "* Region ${YELLOW} $region ${NC}"

      # get default vpc
      vpc=$(aws ec2 describe-vpcs --filter Name=isDefault,Values=true --output text --query 'Vpcs[0].VpcId')
      if [ "${vpc}" = "None" ]; then
        echo "${INDENT}No default vpc found"
        continue
      fi
      echo "${INDENT}Default vpc found: ${BLUE} ${vpc} ${NC}"
      ################## Confirm next action ####################
      PS3="${RED}Select action and press enter: ${NC}"
      echo
      options=("delete" "skip this region" "exit script")
      select opt in "${options[@]}"
      do 
        case $opt in 
            "delete")
            break;;
            "skip this region")
            skipRegion=1
            break;;
            "exit script")
            exit 1;;
            *) echo "invalid option";;
        esac
      done
      # Skip this region if it was selected
      if [ $skipRegion -eq 1 ];then
        skipRegion=0
        continue
      fi
      # get internet gateway
      igw=$(aws ec2 describe-internet-gateways --filter Name=attachment.vpc-id,Values=${vpc} --output text --query 'InternetGateways[0].InternetGatewayId')
      if [ "${igw}" != "None" ]; then
        echo "${INDENT}Detaching and deleting internet gateway ${igw}"
         aws ec2 detach-internet-gateway --internet-gateway-id ${igw} --vpc-id ${vpc}
         aws ec2 delete-internet-gateway --internet-gateway-id ${igw}
      fi

      # get subnets
      subnets=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${vpc} --output text --query 'Subnets[].SubnetId')
      if [ "${subnets}" != "None" ]; then
        for subnet in ${subnets}; do
          echo "${INDENT}Deleting subnet ${subnet}"
           aws ec2 delete-subnet --subnet-id ${subnet}
        done
      fi

      # delete default vpc
      echo "${INDENT}Deleting vpc ${vpc}"
       aws ec2 delete-vpc --vpc-id ${vpc}
      echo
done
