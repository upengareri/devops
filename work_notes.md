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
	- **MUST READ** Packer tutorial for beginners - https://devopscube.com/packer-tutorial-for-beginners/ and official guide - https://learn.hashicorp.com/tutorials/packer/getting-started-build-image
	- To know how to setup jenkins master-slave architecture using packer and terraform, follow the link - https://www.velotio.com/engineering-blog/setup-jenkins-master-slave-architecture
	- Another article to setup windows jenkins slave using packer and terraform - https://www.eficode.com/blog/packer-terraform
	- Snippet from [opstodevops](http://www.opstodevops.tech/blog/2020/06/16/hashicorp-packer-windowsami.html) which says it correctly about packer for aws
```
Packer can build machine images for a number of different cloud platforms but here I will focus on the amazon-ebs builder, which will create an EBS-backed AMI.
At a high level, Packer performs these steps:

Read configuration settings from a json template file
Uses the AWS API to spin up an EC2 instance
Connect to the instance and provision it using WinRM on Port 5986
Shut down and snapshot the instance
Create an Amazon Machine Image (AMI) from the snapshot
Clean up resources like security group, ec2 key-pair and ec2 instance used in the process

Take a note that amazon-ebs builder establishes a basic communicator for provisioning & for Windows it is WinRM on 5985. But for better security & to prevent eavesdropping during image provisioning, I will be using WinRM for HTPPS on Port 5986 by encrypting the traffic using self signed certificate.
```
 

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

-----
Use of Ansible, Packer and Terraform to spin up Windows machine in AWS - https://yetiops.net/posts/packer-ansible-windows-aws/

Comprehensive DevOps Guide - https://devopscube.com/become-devops-engineer/ 

Intersting girl - https://charity.wtf/2016/04/14/scrapbag-of-useful-terraform-tips/

Devops nice articles - https://dvops.cloud/

-----

> [Server For Hackers](https://serversforhackers.com/s/start-here)

### SSH Protocol

| Client        | Server                              |
| ------------- |------------------------------------ |
|id_rsa         |                                     |
|id_rsa.pub     | --(copy)--> |~/.ssh/authorized_keys |

The above diagram shows that we create ssh public and private key pair using `ssh-keygen` (rsa or more recent ecdsa encryption algo type) and then copy the public part to the servers `authorized_keys` file by sshing/logging in to the server.

Now what happens when we perform the ssh - `ssh -i /path/to/private_key` bob@server

1. Server verification by client happens first
	1.1 Server provides its public key/fingerprint
	1.2 Client ssh asks OS - "hey, we are connecting to this guy (public kye). Is this the right guy or is it "man-in-the-middle" attack"?
	1.3 OS checks **known_hosts** file to see any matching public key or fingerprint is found
	1.4 If yes then clinet authenticates server else it prompts us to decide - e.g (github) -

		```
		> The authenticity of host 'github.com (IP ADDRESS)' can't be established.
		> RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
		> Are you sure you want to continue connecting (yes/no)?
		```

		Verify that the fingerprint in the message you see matches GitHub's RSA public key fingerprint. If it does, then type yes

2. Client verification by server happens next
	2.1 SSH asks OS - "hey, bob is asking for connection. This is his private key."
	2.2 OS takes private key and matches with public keys in **authorized_keys** file for a match
	2.3 If yes (matched), then access granted else not

> For more details check - 1. [logging in to your server](https://serversforhackers.com/c/logging-into-your-server) 2. [authorized_keys vs known_hosts](https://security.stackexchange.com/questions/20706/what-is-the-difference-between-authorized-keys-and-known-hosts-file-for-ssh)

> Use cases: 1. **[Jenkins Master-Slave connection](https://dvops.cloud/2019/03/14/configuring-jenkins-slaves-on-aws-ec2/)** 2. [Github ssh](https://docs.github.com/en/github/authenticating-to-github/testing-your-ssh-connection)

### Nginx

- It can act both as web server (serve http content) and as reverse proxy (load balance to backend servers)
- Understands HTTP/S calls and fills/converts into Gateway specific requests
- Also supports caching and storage of static files
- Some useful links:
  - https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
  - https://www.netguru.com/codestories/nginx-tutorial-basics-concepts
  - https://www.youtube.com/watch?v=D5grhfkjjXE
  - http://sawers.com/blog/reverse-proxying-with-nginx/


__File Configurations (in yum/apt base installations):__
* Configuration Files: `/etc/nginx`
* Binary Files: `/usr/sbin/`
* Log Diretory or Files: `/var/log/nginx`
* Data or Documentary Files: `/usr/share/nginx`

__To run nginx in docker:__
```bash
docker run -d \
	--name nginx
	-p 80:80
	-v /var/conf.d:/etc/nginx/conf.d
	nginx
```
Here I have mounted the configuration directory from docker host (/var/conf.d)

To reload nginx gracefully
`nginx -s reload` -s if for signal
To send a signal to reload nginx gracefully in docker
`docker kill -s HUP <container_name>` HUP - Restart Now Signal

__Syntax:__

- Nginx can operate in Layer 7 (HTTP) or Layer 4 (TCP/UDP)
- Using `stream` context it becomes layer 4
- Using `http` context it becomes layer 7

```nginx
worker_processes 2; # directive in global context

http {              # http context
    gzip on;        # directive in http context

  server {          # server context
    listen 80;      # directive in server context
  }
}
```
> **Listen directive:** If not present, it means `*:80` is used; meaning all ips on port 80


	


## AWS Refresher

-----
### Refresher on private subnets
There are basically two differences between a public and private subnet. First of all, a public subnet uses an Internet Gateway. This allows instances in that subnet to communicate with the outside world. Secondly, in order to do this, each instance needs an Elastic IP address.

A private subnet is reachable internally only, while an instance running in a public subnet can be reached directly using the Elastic IP.**The routing table basically determines whether a subnet is private or not.**

In order to obtain a static private IP address, you don't need a private subnet. If your use case allows for the instance to be reachable from the Internet, you might want to use a single public subnet instead. That way you will be able to assign a public (Elastic IP) as well as a private static IP address. You can use security group rules to specify which traffic to allow from the Internet.

-----
Instance profile and role

-----

## GIT gyan

- We have the option in GitLab UI to restrict branch name via regex
  - repo -> settings -> repository -> push rules

-----


## Docker

1. To inspect volumes mounted on a container

`docker inspect -f '{{ json .Mounts }}' containerid | jq `

Notes on docker:
- running on the __daemon__ means running on the background. For e.g nginx when installed runs with `daemon on` i.e in the background
- docker likes to keep track of or monitor the apps running in the foreground and that is why when we use `docker ps` we see the running containers
- if you run an app that runs itself in background (daemon on) the docker loses track of it and quits. So when you run `docker ps` for those cases you'll find no container running
- 

-----

## BASH

- `ps aux`: tells you the processes running

-----

## Random notes

- __Terraform__: any variables that will differ between environments should be exposed as input variables
- __Shell__: `sudo chown -R username:group directory` to recursively change ownership of a directory
- __Manage multiple terraform versions__: `tfenv` and `tgenv` (https://blog.gruntwork.io/how-to-manage-multiple-versions-of-terragrunt-and-terraform-as-a-team-in-your-iac-project-da5b59209f2d#6d29)

-----

# Blogs/Scenarios


## 1. [RDP to Windows EC2 without a bastion host or public subnet](./blogs/rdp_to_ec2.md)
## 2. [Port Forwarding](./blogs/port_forwarding.md)

## 3. [Confluence import failure](https://confluence.atlassian.com/confkb/after-a-failed-space-import-it-s-not-possible-to-re-import-because-of-leftover-space-data-217743668.html)


# Useful Links:

### [Devops pre-requisite](https://www.youtube.com/watch?v=Wvf0mBNGjXY&list=LL&index=2&t=643s)
- Just enough info to get you started about -
	- Linux basic commands
	- Vim
	- Linux package management
	- Linux services (systemctl/service)
	- Virtual Box and Vagrant
	- Networking
		- DNS
		 - /etc/host
		 - resolver
		 - DNS Server
		- Switching and Routing
		- IP Address, Port, Local host

### [Terragrunt Quick Start](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/#keep-your-provider-configuration-dry)
- Major benefits -
	- Keep Backend state DRY
	- Keep Provider DRY
	- Keep CLI DRY
	- Keep use of modules DRY
