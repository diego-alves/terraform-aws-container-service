# Security Group

## Como usar esse modulo?

Esta pasta define um [Módulo Terraform](https://www.terraform.io/docs/modules/usage.html), o qual você pode usar em seu código adicionando uma configuração `module` e configurando o parâmetro `source` para a URL desta pasta: 

```hcl
module "security_group" {
    source = "github.com/hashicorp/terraform-aws-container-service//modules/sg?ref=v0.0.4"
    name = "web-service"
    vpc_id = "vpc-ejfk231lk4"
    ingresses = [
        {port=80, protocol="tcp", cidrs=["0.0.0.0/0"]}
    ]
}
```



