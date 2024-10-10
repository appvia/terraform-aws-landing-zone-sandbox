
check "sso_permitted_permission_sets" {
  assert {
    ## Ensure any rbac roles are defined within the sso_permitted_permission_sets map 
    condition = alltrue([
      for k in keys(var.rbac) : contains(keys(local.sso_permitted_permission_sets), k)
    ])
    error_message = "The following roles are not defined within the permitted roles"
  }
}
