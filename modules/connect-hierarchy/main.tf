resource "aws_connect_user_hierarchy_structure" "this" {
  instance_id = var.instance_id

  hierarchy_structure {
    level_one {
      name = "Project"
    }
    level_two {
      name = "Group"
    }
    level_three {
      name = "Role"
    }
  }
}

# ------------------------
# Level 1: Projects
# ------------------------
resource "aws_connect_user_hierarchy_group" "projects" {
  for_each    = var.projects
  instance_id = var.instance_id
  name        = each.key
}

# ------------------------
# Delay after Projects
# ------------------------
resource "null_resource" "wait_after_projects" {
  provisioner "local-exec" {
    command = "sleep 25"
  }

  depends_on = [
    aws_connect_user_hierarchy_group.projects
  ]
}

# ------------------------
# Level 2: Groups
# ------------------------
resource "aws_connect_user_hierarchy_group" "groups" {
  for_each = {
    for group_key in flatten([
      for project_key, group_map in var.projects : [
        for group_key in keys(group_map.groups) : {
          key       = "${project_key}-${group_key}"
          name      = group_key
          parent_id = aws_connect_user_hierarchy_group.projects[project_key].id
        }
      ]
    ]) : group_key.key => group_key
  }

  instance_id     = var.instance_id
  name            = each.value.name
  parent_group_id = each.value.parent_id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [parent_group_id]
  }

  depends_on = [
    null_resource.wait_after_projects
  ]
}

# ------------------------
# Delay after Groups
# ------------------------
resource "null_resource" "wait_after_groups" {
  provisioner "local-exec" {
    command = "sleep 25"
  }

  depends_on = [
    aws_connect_user_hierarchy_group.groups
  ]
}

# ------------------------
# Level 3: Roles
# ------------------------
resource "aws_connect_user_hierarchy_group" "roles" {
  for_each = {
    for role_key in flatten([
      for project_key, group_map in var.projects : [
        for group_key, role_map in group_map.groups : [
          for role in role_map.roles : {
            key       = "${project_key}-${group_key}-${role}"
            name      = role
            parent_id = aws_connect_user_hierarchy_group.groups["${project_key}-${group_key}"].id
          }
        ]
      ]
    ]) : role_key.key => role_key
  }

  instance_id     = var.instance_id
  name            = each.value.name
  parent_group_id = each.value.parent_id

  lifecycle {
    create_before_destroy = true
    ignore_changes = [parent_group_id]
  }

  depends_on = [
    null_resource.wait_after_groups
  ]
}
