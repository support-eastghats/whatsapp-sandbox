# test/envs/dev/hierarchy_test.tf

provider "aws" {
  region = "eu-west-2"
}

data "aws_connect_instance" "default" {
  instance_alias = "eastghats-prod"
}

module "connect_hierarchy" {
  source      = "../../modules/connect-hierarchy"
  instance_id = data.aws_connect_instance.default.id

  projects = {
    Project1 = {
      groups = {
        Support = {
          roles = ["Level1", "Level2"]
        },
        Sales = {
          roles = ["Level1", "Level2"]
        }
      }
    },
    Project2 = {
      groups = {
        Tech = {
          roles = ["Level1", "Level2"]
        },
        QA = {
          roles = ["Level1", "Level2"]
        }
      }
    }
  }
}

output "project_ids" {
  value = module.connect_hierarchy.project_hierarchy_ids
}

output "group_ids" {
  value = module.connect_hierarchy.group_hierarchy_ids
}

output "role_ids" {
  value = module.connect_hierarchy.role_hierarchy_ids
}
