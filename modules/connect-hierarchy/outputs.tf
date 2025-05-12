output "project_hierarchy_ids" {
  value = { for k, v in aws_connect_user_hierarchy_group.projects : k => v.id }
}

output "group_hierarchy_ids" {
  value = { for k, v in aws_connect_user_hierarchy_group.groups : k => v.id }
}

output "role_hierarchy_ids" {
  value = { for k, v in aws_connect_user_hierarchy_group.roles : k => v.id }
}
