override['nginx']['client_max_body_size'] = "20M"
override['nginx']['proxy_read_timeout']   = 60
override['nginx']['proxy_send_timeout']   = 60
override['nginx']['repo_source']          = "nginx"
if node.platform == "ubuntu"
  override["nginx"]["version"] = "1.8.0-1~trusty"
elsif node.platform_family == "rhel"
  override["nginx"]["version"] = "1.8.0-1.el6.ngx"
end
