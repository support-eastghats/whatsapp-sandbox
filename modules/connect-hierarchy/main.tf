resource "aws_connect_user_hierarchy_structure" "this" {
  instance_id = var.instance_id

  hierarchy_structure {
    level_one  { name = "Project" }
    level_two  { name = "Group" }
    level_three { name = "Role" }
  }
}

# -------------------------
# Level 1: Projects
# -------------------------
resource "aws_connect_user_hierarchy_group" "projects" {
  for_each    = var.projects
  instance_id = var.instance_id
  name        = each.key

  depends_on = [aws_connect_user_hierarchy_structure.this]
}

# Artificial delay to allow projects to be fully available
resource "null_resource" "wait_after_projects" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [aws_connect_user_hierarchy_group.projects]
}

# -------------------------
# Level 2: Groups
# -------------------------
resource "aws_connect_user_hierarchy_group" "groups" {
  for_each = {
    for combo in flatten([
      for project_name, group_map in var.projects : [
        for group_name in keys(group_map.groups) : {
          key       = "${project_name}-${group_name}"
          name      = group_name
          parent_id = aws_connect_user_hierarchy_group.projects[project_name].id
        }
      ]
    ]) : combo.key => combo
  }

  instance_id       = var.instance_id
  name              = each.value.name
  parent_group_id   = each.value.parent_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [parent_group_id]
  }

  depends_on = [null_resource.wait_after_projects]
}

# Artificial delay to allow groups to propagate
resource "null_resource" "wait_after_groups" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [aws_connect_user_hierarchy_group.groups]
}

# -------------------------
# Level 3: Roles
# -------------------------
resource "aws_connect_user_hierarchy_group" "roles" {
  for_each = {
    for combo in flatten([
      for project_name, group_map in var.projects : [
        for group_name, role_obj in group_map.groups : [
          for role_name in role_obj.roles : {
            key       = "${project_name}-${group_name}-${role_name}"
            name      = role_name
            parent_id = aws_connect_user_hierarchy_group.groups["${project_name}-${group_name}"].id
          }
        ]
      ]
    ]) : combo.key => combo
  }

  instance_id       = var.instance_id
  name              = each.value.name
  parent_group_id   = each.value.parent_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [parent_group_id]
  }

  depends_on = [null_resource.wait_after_groups]
}
