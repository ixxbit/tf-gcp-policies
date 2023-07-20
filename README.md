
`gcloud beta terraform vet`

In this demo, we will use `terraform` and `gcloud beta terraform vet` to perform our policy validation process.


### DEMO PART I: SETTING UP THE TF ENVIRONMENT

  

- Meet prerequisites for policy validation using Terraform

- Configure our working environment

  

- Policy library overview

  

### DEMO PART II: CONSTRAINING DOMAINS

  

- Apply a constraint that enforces a domain restriction for GCP service account

- Test a constraint to intentionally throw a validation error

- Modify the constraint so that it passes validation

  

- Create a new constraint yaml to enforce domain restrictions for users

  
  
  

----

  

# DEMO PART I

  

### ENV PREREQ'S

**Meeting requirements for policy validation using Terraform**

- GCP

- Cloud Shell or Local Terminal

- gcloud (https://cloud.google.com/sdk/docs/install) with `gcloud beta terraform vet

- Policy-library with constraints to validate against GCP (https://github.com/GoogleCloudPlatform/policy-library.git)

- GCP - account should have the following [Identity and Access Management (IAM) permissions](https://cloud.google.com/iam)
 `resourcemanager.projects.getIamPolicy`
 `resourcemanager.projects.get`

- Terraform 1.1+

  
  

### ENV CONFIG

**Our working directory must include the policy library, provided by Google Cloud Platform in hithub**

- Cloning the policy library repository.

`git clone https://github.com/GoogleCloudPlatform/policy-library.git`

- Install/Update the **Terraform Tools** component (linux/mac)

`sudo apt-get install google-cloud-sdk-terraform-tools`

`gcloud components update`

- Verify tools issue:

- ` terraform --version

- ` gcloud beta terraform vet

  

### Directory Overview

`policy-library/`

- `policies/` — This directory contains two subdirectories:

- `constraints/` — **This directory is initially empty. Place your constraint files here.**

- `templates/` — This directory contains pre-defined constraint templates.

- `samples/` — **This directory contains sample constraints.**

- `validator/` — This directory contains the .rego files and their associated unit tests. You don’t need to touch this directory unless you intend to modify existing constraint templates or create new ones. Running “make build” inlines the Rego content in the corresponding constraint template files.

  
  

----

  
  

# DEMO PART II

  

## Validating GCP IAM Allowed Policy with customized constraints

  

To see how a constraint is implemented, we'll copy an existing constraint, provide a test case that fails validation, and then modify the constraint so that it passes.

  

#### Preparing contraint(s)

- Copy over the sample IAM domain restriction constraint

`cd policy-library/`

`cp samples/iam_service_accounts_only.yaml policies/constraints`

  

## Review

- Constraint details

`cat policies/constraints/iam_service_accounts_only.yaml`

- This constraint checks that all IAM policy members are in the "gserviceaccount.com" domain.

output:

```

apiVersion: constraints.gatekeeper.sh/v1alpha1

kind: GCPIAMAllowedPolicyMemberDomainsConstraintV2

metadata:

name: service_accounts_only

annotations:

description: Checks that members that have been granted IAM roles belong to allowlisted

domains.

spec:

severity: high

match:

ancestries:

- "organizations/**"

parameters:

domains:

- gserviceaccount.com

```

**This specifies that only members (users or service accounts) belonging to  `gserviceaccount.com` domain will be validated and allowed to proceed forward with the task.**

  
#### Modify the yaml file
`policies/constraints/iam_service_accounts_only.yaml`
- under ancestries change ` "organizations/**"` to `"projects/**"`

  
  

### IAM Roles

  

Identity and Access Management (IAM) roles are collections of IAM permissions.

  

A role (viewer, editor, owner) contains a set of permissions that allows you to perform specific actions on Google Cloud resources.

To make permissions available to principals you grant roles to principals, including:

- users

- groups

- service accounts

  
  

#### Create Terraform script

We'll create a Terraform file with instructions to bind a role to a user within a given project

  

- Create a new terraform file `policy-library/main.tf` and add:

```

terraform {

required_providers {

google = {

source = "hashicorp/google"

version = "~> 3.84"

}

}

}

resource "google_project_iam_binding" "sample_iam_binding" {

project = "<YOUR PROJECT ID>"

role = "roles/viewer"

members = [

"user:<USER>"

]

}

```

  

- Replace `<YOUR PROJECT ID>` with `Project ID`.

- Replace `<USER>` with `GCP account/ username`.

....

.......

  

```

terraform {

required_providers {

google = {

source = "hashicorp/google"

version = "~> 3.84"

}

}

}

resource "google_project_iam_binding" "sample_iam_binding" {

project = "xtf-validator"

role = "roles/viewer"

members = [

"user:ixxbit@gmail.com"

]

}

```

  

.......

....

  

#### Execute Terraform Commands

  

- Run the following commands to initiate (current directory `policy-library` )

`terraform init`

  

- Export the Terraform plan

`terraform plan -out=test.tfplan`

  

- Convert the Terraform plan to JSON

`terraform show -json ./test.tfplan > ./tfplan.json`

  

#### Validate our plan with our policies

  

- Verify the policy constraint(s) and validate that our tfplan complies with our policies. ` tfplan.json` is used as our input:

`gcloud beta terraform vet tfplan.json --policy-library=.`

  
**Since the email address we provided in the IAM policy binding does belong to an allowed domain this terraform plan does pass the validation process

```
Processing...Done
```