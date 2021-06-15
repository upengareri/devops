# Terraform Basics

## Types of IaC Tools
![iac_tools](./images/iac_tools.png)

    1. Configuration Management Tools
        - Designed to install and manage softwares
        - Maintains standard structure on multiple servers at once
        - Version control e.g ansible playbook and role can be checked into version control repository
        - Idempotent (best feature): remembers the state
    
> Summary: You can install softwares, you can install softwares on many servers at once, you can verison controll the whole installation process and settings, install many times without worrying about errors and overrides as it is idempotent and remembers the state

    2. Server Templating Tools
        - Designed for creating __CUSTOM IMAGE__ for virtual machine or container
        - These images already contain all the softwares and dependencies on them thus eliminating the need for installing softwares after the images or containers are deployed
        - Examples of the images include custom AMIs on aws and docker images on docker hub and other cotainer registries
        - Unlike configuration management tools, server templating tools are __IMMUTABLE__ meaning once the image or containers are deployed they remain unchanged. If any change is to be made, we update the image and re-deploy the instance/container using the updated image

> Summary: Remember custom AMIs and docker images that have OS with pre-installed softwares and dependencies; any update will require re-deployment of image

    3. Provisioning Tools
        - Designed for deploying immutable infrastructure resources such as servers, db, network components
-----
## Intro
- Terraform is __DECLARATIVE__ meaning:
    - You declare the desired state and it'll _take care_ of __WHAT IS REQUIRED__ to go from __CURRENT STATE TO DESIRED STATE__
- Terraform uses 3 phases for achieving the desired state:
    1. `INIT` initialises the project and identifies the providers to be used for target environment
    2. `PLAN` drafts a plan to get to the desired/target state
    3. `APPLY` makes the necessary changes in the environment to bring it to the desired state
- Every object terraform manages is called __RESOURCE__
- Terraform __STATE__ is the blueprint of the infrastructure deployed by terraform
    ![tf_state](./images/tf_state.png)
- Terraform can also manage other resources that were created manually or by other IaC tools using __TERRAFORM IMPORT__

-----
## HCL (HarshiCorp Configuration Language) Bascis
- HCL syntax follow the following structure
<a id="tf-syntax"></a>
```hcl
<block> <parameters> {
    key1 = value1
    key2 = value2
}
```
- We'll take a simple example of creating a file locally where terraform is installed
    - For this we'll create a terraform configuration file called, for e.g, local.tf
    ![file_example_tf](./images/file_example_tf.png)
        - The first element is a `resource block`. We can have other types of block as well
        - Following that we have `resource type` which has fixed value. It gives us 2 bits of information - `provider` and `resource`
        - The final parameter for this resource block is the logical `resource name` used to identify that resource. It can be named anything
        - The keys are fixed/specific and depend on the `resource type` that we use. In case of "local_file" resource type, the only mandatory argument is `filename`

> `resource` block is one of the many blocks that we have in TF. It is also the only mandatory block that TF requires to deploy any resource

- A simple terraform workflow consists of 4 simple steps:
    1. Write configuration file
    2. `terraform init` out of many things it checks and configures, one is to read the provider and download necessary plugins related to the provider to work on the resource declared in the .tf file in step 1
    3. `terraform plan` optional to check the execution plan that will be carried out
    4. `terraform apply`

- `terraform show` inspects the state file and shows the resource details

> It is impossible to remember all types of providers and resource types and thus we can look at the terraforms comprehensive documentation to know the resource and their arguments

### Create, Update and Destroy of Resource
__Create File__
```hcl
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
}
```
__Update File__
```hcl
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
    file_permission = "0700"
}
```
- By default the file is created with 777 permission and thus in the above command we are updating it
- When we run `terraform plan`, it shows "-/+" before the resource syntax which implies that the resource will be deleted and then re-created
- Even though the change looks trivial, tf will delete the old file and create a new file with new changes and this type of infrastructure is called __immutable infrastructure__

__Destory File__

`terraform destroy`

-----




-----
# SUMMARY
- [Terraform Syntax](#tf-syntax)