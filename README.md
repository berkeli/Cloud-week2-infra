# CodeYourFuture Cloud Module IaC (Infrastructure as Code) Guide

## Getting started with terraform

In order for terraform to work on your local machine, you will need to have AWS cli working locally with profiles configured.

### Install AWS CLI - [AWS CLI Installation]([https://](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))

To verify the installation of AWS CLI run the following command in your terminal:

`aws --version`

AWS CLI lets you do pretty much anything you can do in the AWS Console via commands.

In order for the CLI to connect to your AWS account, you will need to configure credentials locally. To do so:

1. Create Access Key for your account by following [this guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds-create)

Access key ID & Secret access key act as passwords, and you should never share these with anyone or in commit them to your github repository. Treat them as if they were your passwords!

2. Open the terminal in your computer and type in `aws configure`. This will open a prompt that will ask you to enter the following:
   1. Access key ID (obtained in previous step)
   2. Secret access key (obtained in previous step)
   3. Region (this will be default region where resources are created, you can put `eu-west-2` for London)
   4. [Output format](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html) (you can type json, this will format the data if you use AWS CLI to list resources such as users)
   
3. If you followed these steps correctly, your aws cli should now be able to talk to your AWS account. If you have any resources, you can try to list them with commands: `aws ec2 describe-instances`

The format of commands is always `aws <service> <command> <options>`

Now that you have aws CLI configured it's time to install terraform. Follow [this link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) and follow the guide for your OS.

Once installed, you should be able to run `terraform -v` to make sure it's installed.

## Getting started with terraform

In any folder, create a file with `.tf` extension. Best practice is to name the main configuration file `terraform.tf` This file will contain our provider configuration.

What are providers? Providers are AWS, Google Cloud, Azure and etc. There are many, many providers - https://registry.terraform.io/browse/providers

For our use case we will be using AWS, so to declare a provider we use the following syntax:

```
provider "aws" {
  region  = "eu-west-2"
}
```

As simple as that!
There are many different options you can provide to customize it. For example, one of the best practices is to tag all of the resources so you know why they were created in the future:
In the below example, all of the resources created with this terraform code will be tagged with `project = "cloud-module"` and `terraform = true` you can add as many or as little as you like.

Another option is profile, which is used if you have multiple AWS accounts. For example, you might be working for a company that manages many departments and each has their own profile. In that case, the profile must first be configured in your AWS CLI. [Guide here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) but you can ignore this part for now.

```
provider "aws" {
  region  = "eu-west-2"
  profile = "personal"

  default_tags {
    tags = {
      terraform = "true"
      project   = "cloud-module"
    }
  }
}
```

There's one more block of code we need to add for our first IAC project to be functional:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

This tells terraform which version of aws provider to use.

The final terraform.tf can be found in the [terraform](terraform/terraform.tf) folder

Once you have created this file we are ready to start building infrastracture with code but first we need to learn a few terraform CLI commands:

1. `terraform init` - this will initialize the project and install all required modules (if you have any). Think of it like `npm install` in node.js. This command will also ensure terraform and aws setup correctly on your machine.
2. `terraform plan` - this command will check your code and plan out the release of code. It will check what needs to be removed, added or changed.
3. `terraform apply` - this command will go ahead and make the changes shown in plan.
4. `terraform destroy` - this command will remove everything created with this project from your aws profile. No need to manually delete instances in fear of a huge bill, it can be done with 1 command.

`terraform apply` and `terraform destroy` will always ask you before making any changes. You will need to explicitly respond with `yes` to proceed with changes.

Now you can go ahead and run `terraform init` to get started.

### Resources, data, modules...

#### **Resources** declare things that you would like to create, e.g. new ec2 instance, new VPC, subnet etc.
#### **Data** declare things that you already have in your aws account but would like to reference in your terraform code. For example, every account comes with a default VPC and Subnet, so if you want to create a new instance and add it to this subnet, you will need to `import` them into your code using `data`
#### **Modules** are like npm modules, these can be created by yourself or you can use any one of 1000s modules [readily available](https://registry.terraform.io/browse/modules). Modules usually will take in parameters (like functions) and output parameters as well.

### Creating our first EC2 instance

To create and EC2 instance, we need a couple of things first:
1. AWS key pair - this is a pair of keys (private and public) that allow you to connect to other computers via SSH. You will store the public key on the server and the private key on your computer. This can be generated by terraform, but it's best practice to NOT do that and generate it away from terraform. The reason being is that terraform creates state files that store this information and if you commit state somewhere public, it can reveal your keys.

To generate a key pair, the easiest way is to do it via AWS console:
1. Login to your account
2. Go to EC2 Service
3. Select Key pairs from the left hand side menu
4. Select new key pair
5. Leave everything default, give it a name.
6. This will give you a file to download, save it in your `~/.ssh` folder. You can save the file anywhere, but it's best practive to use .ssh








