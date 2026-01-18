output "function_app_name" {
  value = module.app.function_app_name
}

output "api_endpoint" {
  value = "https://${module.app.default_hostname}/api"
}
