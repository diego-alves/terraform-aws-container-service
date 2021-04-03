package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestContainerServiceExample(t *testing.T) {
	t.Parallel()
	expectedRegion := "us-east-1"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/container-service",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": expectedRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "repository_url")
	assert.Regexp(t, "\\d{12}.dkr.ecr."+expectedRegion+".amazonaws.com/container_service_module_test", output)
}
