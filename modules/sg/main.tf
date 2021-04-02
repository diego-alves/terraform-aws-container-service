# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource aws_security_group secgroup {
    name = "${var.name}-sg"
    vpc_id = var.vpc_id

    dynamic "egress" {
        for_each = var.egresses
        content {
            from_port   = egress.value["port"]
            to_port     = egress.value["port"]
            protocol    = egress.value["protocol"]
            cidr_blocks = egress.value["cidrs"]
        }
    }

    dynamic "ingress" {
        for_each = var.ingresses
        content {
            from_port   = ingress.value["port"]
            to_port     = ingress.value["port"]
            protocol    = ingress.value["protocol"]
            cidr_blocks = ingress.value["cidrs"]
        }
    }
}

