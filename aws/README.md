# Stickyness Strategy for AWS Application Load Balancer
> Based on: https://docs.aws.amazon.com/prescriptive-guidance/latest/load-balancer-stickiness/

There are four stickiness strategies discussed in the prescriptive guidance mentioned above. Each CloudFormation template implements one of the strategies. CloudFormation templates are modified to be deployed in 'eu-north-1'. In addition, AMIs and instance types are modified to use free EC2 tier in the new region. 

## Notes:
* You need to create a key pair named 'Test1' in your environment. 
* To avoid costs, I recommend [creating](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html) and [deleting](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html) each stack before trying other ones. 