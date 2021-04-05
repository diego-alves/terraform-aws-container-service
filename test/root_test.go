package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestRootModule(t *testing.T) {
	t.Parallel()
	expectedRegion := "us-east-1"
	expectedZone := "myzone.com"
	expectedECSCluster := "mycluster"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": expectedRegion,
		},
		Vars: map[string]interface{}{
			"name":         "module-test",
			"zone":         expectedZone,
			"cluster_name": expectedECSCluster,
			"extra_services": map[string]interface{}{
				"api": map[string]interface{}{
					"paths":    []string{"/docs", "/api/*"},
					"hc_path":  "/api/v1/health/",
					"port":     80,
					"cpu":      256,
					"mem":      512,
					"replicas": 2,
					"environment": map[string]string{
						"WEB_CONCURRENCY": "1",
						"ACC_SERVICE":     "svcacc_tesseract@uolinc.com",
					},
					"secrets": map[string]string{
						"ACC_SERVICE_PW": "svcaccTesseractPassword",
					},
				},
			},
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	defaultService := terraform.OutputMap(t, terraformOptions, "default_service")

	assert.Regexp(t, "\\d{12}.dkr.ecr."+expectedRegion+".amazonaws.com/module-test", defaultService["docker"])
	assert.Equal(t, "module-test", defaultService["name"])
	assert.Equal(t, "https://module-test."+expectedZone, defaultService["url"])
}
