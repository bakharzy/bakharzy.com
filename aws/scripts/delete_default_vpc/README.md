# Delete default VPCs in all selected regions in an AWS account
The script "default_vpc_delete.sh" checks if there is a default VPC exist in each region within an AWS account. You can modify the regions in REGIONS variable. If a default VPC is found, the script will ask what to do next. Next actions are: 
1. delete the VPC
2. skip this region
3. exit script

Read more in the blog post below:

> Blog post: https://bakharzy.com/2023/07/02/delete-aws-default-vpcs-with-aws-cli/

### Use the default_vpc_delete.sh script: 

```
bash default_vpc_delete.sh
```
This script is tested in AWS CloudShell environment. 