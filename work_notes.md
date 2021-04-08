This page is about general doubts, trivial points and notes on some hacks.

1. Installing zsh in ubuntu: https://medium.com/wearetheledger/oh-my-zsh-made-for-cli-lovers-installation-guide-3131ca5491fb

2. How to make alias of python3 as python
	go to .bashrc or .zshrc or whatever you’re using and put 
		`alias python3=python`



Find answer:

1. Best practices for using shell script in jenkins
Use case could be to eg check if docker image is there in ecr or not.


----- 
DevOps Notes:

- **Machine image**
	- It usually contains pre-installed OS and software packages. Amazon provides machine image which we can _launch->configure->create image->launch_
	- Once we launch it, it's called running machine
	- Machine image can also be termed "pre-baked" image
	- To launch the pre-baked image we can use "Launch template"

- **Packer**
	- It's a tool provided by HashiCorp to create "pre-baked" images
	- In AWS, we can do this with CloudFormation itself
	- Packer does not manage the image. Packer only builds images. After they're built, it is up to you to launch or destroy them
	(HashiCorp has separate tool for creating pre-baked images (packer) and separate tool for provisioning (terraform). We just need to create a JSON file and pass installation script as user-data as part of creation in terraform and it will take care of developing the AMI for us.)
	- **To know how to setup jenkins master-slave architecture using packer and terraform, follow the link - https://www.velotio.com/engineering-blog/setup-jenkins-master-slave-architecture **

- **Ansible**
	- It's a configuration management tool that can be used to install packages
	- It's other alternatives are Chef, Puppet and Salt


---
Use of Ansible, Packer and Terraform to spin up Windows machine in AWS - https://yetiops.net/posts/packer-ansible-windows-aws/
Comprehensive DevOps Guide - https://devopscube.com/become-devops-engineer/ 
Intersting girl - https://charity.wtf/2016/04/14/scrapbag-of-useful-terraform-tips/ 

