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
	- **Beginner tutorial on Packer with examples: https://devopscube.com/packer-tutorial-for-beginners/**

- **Ansible**
	- It's a configuration management tool that can be used to install packages
	- It's other alternatives are Chef, Puppet, Salt, Shell, Powershell
	> _Terminologies_: Playbook, plays, hosts, tasks: A playbook is an yaml file that consists of one or more plays. A play contains hosts and tasks. A hosts is where the tasks will run. A task is an action to be applied.

	> Inventory: An inventory file defines the hosts and host groups on which the tasks are applied. By default ansible uses “/etc/ansible/hosts” as the default inventory. Of course you can create your own inventory and use -i flag to tell ansible to use your inventory rather than the default one.
	
	> Control Host: It is a host from where ansible commands will be run. Control host will need ssh access to target hosts to be able to login and run the automation.

	- Useful Beginner Links
		1. Configure Ansible Server and Hosts - https://devopscube.com/install-configure-ansible-server-nodes/ 
		2. https://medium.com/@sixev/how-to-get-started-with-ansible-in-10-minutes-e174037341f3
		3. **MUST READ** - https://www.guru99.com/ansible-tutorial.html#1
		4. **DETAILED** - https://serversforhackers.com/c/an-ansible2-tutorial


---
Use of Ansible, Packer and Terraform to spin up Windows machine in AWS - https://yetiops.net/posts/packer-ansible-windows-aws/

Comprehensive DevOps Guide - https://devopscube.com/become-devops-engineer/ 

Intersting girl - https://charity.wtf/2016/04/14/scrapbag-of-useful-terraform-tips/ 

