# Overview

This is the SYSTEM infrastructure repo for BuzzLink - a wildly successful url shortening service company.

The SYSTEM infrastructure will consistent of resources that are shared across BuzzLink services.

# Getting Started

Microsoft has some excellent examples and documentation over on [Github](https://github.com/Azure/bicep). There is a video introducing bicep that I highly recommed for the short version.  
Extra examples about create and deploy different resources using Bicep on [Azure Quickstart Template](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts)

[Getting started with Bicep](https://github.com/Azure/bicep#get-started-with-bicep) will help install tools and a deeper overview of Bicep on Microsoft Learn.

**Requirements**

1. Azure Bicep installed
2. Have the **Contributor** (minimally) Azure role. **Everyone** on the team should already be in the security group that provides this as part of onboarding.

> NOTE: One thing **Contributors cannot do is anything related to role assignments**. Today, this requires the **Owner** Azure role and few people will have that, however, the pipeline **will** have that role. Therefore, anyone should be able to do role assignments, as long as they are being created as part of a pipeline execution.

## Running Bicep Locally

These steps will help you execute your bicep code from local machine. It will create Azure resources that you can setup/teardown at will. This is often helpful to get something running, verified, and then tear it down and let the pipeline do it.

### Creating Infrastructure

Here we are assuming we haven't already logged in, set our subscription, and created our resource group.

```
az login
az account set --subscription "sub-zach-01"
az group create --name rg-buzzlink-sys-dev-scus-01 --location southcentralus --tags app-contact=zachbonham@gmail.com app-environment=dev
az deployment group create --resource-group rg-buzzlink-sys-dev-scus-01 -f .\main.bicep --parameters contact=zachbonham@gmail.com environment=dev
```

### Clean Up Infrastructure

Here we are assuming we haven't already logged in and set our subscription.

```
az login
az account set --subscription "fs-dev-001"
az group delete --name rg-buzzlink-sys-dev-scus-01
```

## Troubleshooting

TBD. They are most likely permission related.
