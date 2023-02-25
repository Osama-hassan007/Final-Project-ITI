# Final-Project-ITI

## Creating CI CD Using AWS EKS

### This project about

      *  building complete infrastructure and deploy Nodejs Application of AWS EKS Cluster.
      *  Create jenkins deployment in spicific namespace and the application in a different one 
      *  use a customized image for jenkins that includes docker and kubectl utilities!

## Tools Used:
1- Terraform infrastructure as a code to build the infrastructure, Terraform code includes:
```bash
  * VPC
  * Public subnets
  * Private subnets
  * EKS cluster with workernode and roles
  * Internet gateway
  * Nat gateway
  * route tables
  * Bastion Host
```
### Bastion Host is used to ssh to the private workernode and configure to install Docker and can configure that step with Ansible
```bash
sudo yum update -y
sudo yum install -y docker git
sudo service docker start

```
2- AWS EKS:
```bash
Used to deploy my Nodejs Application
```
### Note: to be able to use EKS cluster use command : 

```bash
aws eks --region <region-name>  update-kubeconfig --name <cluster name>
```
---
3- Docker:
```bash
Used to build dockerfiles for jenkins and the application
```
---
4- Jenkins:
```bash
Used to make the CI CD part and make a complete pipeline
```
## App Rebo That Used At CI CD Stages [here](https://github.com/Osama-hassan007/App-For-Final-Project.git)

## You Can Check the live Apllication from [here](http://aef12c5d691ac40888d42a83c3522063-94c1cc601b4c7be7.elb.us-west-1.amazonaws.com/)

