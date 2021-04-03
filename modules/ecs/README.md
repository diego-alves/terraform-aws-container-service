# ECS Service Module

This folder contains a Terraform Module to create an AWS ECS Service to run a container application.

## How to use this module

To use this module include a `module` resource and configure the source to this folder.

```hcl
module "my_app" {
  source = "github.com/diego-alves/terraform-aws-container-service//modules/ecs?ref=v0.0.5"
  name = "my-app"
}
```

