Infra folder contains the terraform code for deploying the infrastructure and also the round robin script.
In the main folder is also located the azure-pipeline.yml where is the code for the pipeline. Playbook.yml is ansible playbook to run the round robin script on every ec2 instance.

This is a pipeline that deployes an aws infrastucture with any number of ec2 instances you desire and does a round robin ping between them using ansible.
The pipeline is composed of 3 Stages
First stage it install the terraform and all dependencies.
Second stage it deploys the infrastructure
Third stage install ansible and runs the script on each vm.

The agent for the pipeline is hosted in another EC2 instance, to make the connection between them possible a vpc peering was made to connect the existing ec2(agent) vpc's with the new created vpc of the instances.
