locals {
    # project identifier
    project_name = "Task-1"

    # Naming Prefix used for all resoources
    name_prefix = "${local.project_name}-${var.environment}"

    # Common tags applied to all resoources
    common_tags = {
        Project     = local.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Owner       = "kanvit"
        Application = local.project_name
    }
}