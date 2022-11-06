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

To create and EC2 instance, we need an aws_key_pair that we can attach to our EC2 instance:
AWS key pair - this is a pair of keys (private and public) that allow you to connect to other computers via SSH. You will store the public key on the server and the private key on your computer. This can be generated by terraform, but it's best practice to NOT do that and generate it away from terraform. The reason being is that terraform creates state files that store this information and if you commit state somewhere public, it can reveal your keys.

To generate a key pair, the easiest way is to do it via AWS console:
1. Login to your account
2. Go to EC2 Service
3. Select Key pairs from the left hand side menu
4. Select new key pair
5. Leave everything default, give it a name.
6. This will give you a file to download, save it in your `~/.ssh` folder. You can save the file anywhere, but it's best practive to use .ssh folder for your private keys.

Once you have created a key pair, we can start building our infrastracture.

1. [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) - Virtual Private Cloud. This is kind of a network where services can live. Every account gets a default VPC, but for this tutorial we will be creating a new one.

Pay attention to the syntax - terraform resources are declared the following way.
resource <resource you want to use> <name>

* resource you want to use has to be ony of the resources available within a provider. You can always search the [terraform registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for available resources.

```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

The code above is all it takes to create a new VPC, and all of the services inside it will have an IP address that's withing the CIDR block we've defined. You can [read](https://www.techtarget.com/searchnetworking/definition/CIDR#:~:text=CIDR%20(Classless%20Inter%2DDomain%20Routing)%20%2D%2D%20also%20known%20as,B%20and%20Class%20C%20networks.) here about CIDR blocks, but in short it means our VPC will have 65,536 unique IP addresses starting from  10.0.0.0 to 10.0.255.255

2. [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) - this is a private network within a VPC, a VPC can have many subnets within it.

```
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
  availability_zone = "eu-west-2a"
}
```
We are providing a bit more options in this case:
* vpc_id - subnets belong to VPCs so we are attaching it to our newly created VPC. 
* cidr_block - subnets also have their own dedicated IP addresses, in this case we are using a [function](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet) provided by terraform to calculate the CIDR block for the subnet
* availability_zone - each AWS region has multiple datacenters, which are identified as availability zones. 

3. We now have a fully functional network in the cloud, but we need to connect it to the internet. This is where [api internet gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) comes in.

```
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```
Here we only provide the VPC id where we want to create internet gateway. 

4. Now we need to route traffic to the internet. To do that, we need a [routing table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table). Just like the name suggests, it works like a router. 

```
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main.id
}
```
In the code above, we create a route table and attach it to the subnet we created earlier. This way, our subnet can now connect to the internet and is no longer a private network.

5. Now that we have our networking setup, we need a [security group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) which is a firewall. Security group decides who can connect to what.

```
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  egress = [
    // allow outbound traffic to the internet
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    // allow inbound traffic on port 22 which is used for SSH-ing into the ec2.
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    // allow traffic on port 80 from everywhere, this is the default port for HTTP
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    // allow traffic on port 5000 this is for 1 of the APIs, notice we are not providing "0.0.0.0/0" in CIDR blocks and we marked self as true, this port is open only for services already in this security group so you can't access it from public.
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 5000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 5000
    },
    // allow traffic on port 5001 this is for the other API. Same as above, this is not accessible pulicly
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 5001
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 5001
    },
  ]
}
```
That might seem a lot of code, but let's break it down. Security group has 3 main options that you need to provide:
   1. The VPC it belongs to, in our case we link it to the main VPC we created earlier.
   2. Ingress - this is an array of rules for inbound traffic
   3. Egress - this is an array of rules for outbound traffic

Let's take a look at the format for rules:

```
  {
      cidr_blocks      = ["0.0.0.0/0", ] // IP addresses to allow, in this case everyone 
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1" // -1 stands for all protocols
      security_groups  = [] // if you want to allow traffic from other security groups, you can provide IDs
      self             = false // if you want to allow traffic from this security group.
      to_port          = 0
  }
```
6. Now that we have our Networking completely setup, we can start creating [EC2 instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
```
resource "aws_instance" "api" {
  // here we provide AWS Image ID. I'm using Amazon Linux 2 image, but you can use ubuntu or any other image.
  ami                         = "ami-06672d07f62285d1d"
  // here we provie t2.micor as instance type, which is the cheapest ec2 instance and eligible for free tier.
  instance_type               = "t2.micro"
  //key name will be for the key you created earlier.
  key_name                    = "Berkeli"
  //here we attach it to the subnet we created earlier
  subnet_id                   = aws.aws_subnet.public.id
  //here we indicate that we want a public IP attached
  associate_public_ip_address = true
  //below we indicate which security groups should be attached to this instance
  vpc_security_group_ids      = [aws_security_group.main.id]

  tags = {
    Name = "API-1"
  }
```

This is all it takes to create and EC2 instance, but it will not have any of your apps or APIs. Instead of connecting to each instance manually and configuring it via SSH, we can provision these instances within terraform.

### Provisioning instances

Terraform offers a way to connect to the instance and run commands. To connect to the instance, it needs to have a publicly accessible IP or DNS.

To do this, we will be creating and Elastic IP and attaching it to the EC2 instance with the following code:

```
resource "aws_eip" "ip" {
  vpc = true
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.api.id
  allocation_id = aws_eip.ip.id
}
```
After adding this code, our EC2 instance will now have a public ip that can be accessed with `self.public_ip`. We will modify the code we wrote for aws_instance to add connection:

```
resource "aws_instance" "api" {
  ... // code from above doesn't change

  // this establishes a connection to EC2 instance after it has been created. Terraform is very smart that it knows to wait for EC2 to be created, IP to be attached and only then attempt connection without requiring any async/await statements.
  connection {
    // type of connection is SSH
    type        = "ssh"
    // this is the default root user for the instance, it will be ec2-user for Amazon Linux and root for ubuntu instances
    user        = "ec2-user"
    // here you will need to provide the private key you saved earlier. Make sure it's the correct path
    private_key = file("~/.ssh/Berkeli.pem")
    // here we provide the IP address to connect to. We are using coalesce function which takes the first value that's not null.
    host        = coalesce(self.public_ip, self.private_ip)
  }

  // the statement below is the code to execute after connection is established. In this case we are installing updates, and installing docker. After installed, we are starting docker service.
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo usermod -a -G docker ec2-user",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service"
      // here you can add any commands that should be executed
    ]
  }
}
```
This will give you a basic idea on how to setup EC2, from here you can enhance it to launch your services. In my use case, I went with an image hosted in public docker repository and launching it on the EC2 instance with following steps.

Let's see and example on API-1

1. Go to the folder of the API-1 and create a dockerfile: 
```
FROM node:12.16.1-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5000

CMD [ "npm", "start" ]
```
2. Now we need to build this docker image and upload it to the [public docker repository](https://hub.docker.com/). Ensure you have docker installed locally and also logged in to docker via terminal. You can run `docker login` to ensure you are logged in.

3. Go to [Docker hub and create a public repository](https://hub.docker.com/)

4. Now we can build the image and upload it to the repository you created:
  
`docker build -t <your_username>/<repo_name>:latest . `  
(don't miss the dot at the end, it means to build it from current directory)

To push the image, you can run the following command:

`docker push <your_username>/<repo_name>:latest`

5. Now that your image is uploaded, we can go ahead and add the command to the EC2 provisioner.

```
provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo usermod -a -G docker ec2-user",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",
      "sudo docker run -dp 5000:5000 --restart unless-stopped <your_username>/<repo_name>:latest:latest"      
    ]
  }
```

And this should have your EC2 instance provisioned with your API-1 without any requirement to do manual configuration.

Please note we have note exposed port 5000 to the public, so it will not be accessible on the IP_ADDRESS:5000. It's only meant to be accessed by your flask app in the private network.

You can adjust your security group settings if you would like to make it publicly accessible or repeat these steps for your flask app and see if it can access it.









