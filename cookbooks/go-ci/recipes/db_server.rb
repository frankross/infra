include_recipe "postgresql::server"
include_recipe "postgresql::contrib"

cookbook_file "/var/go/dbuser_create_psql.sh" do
  source "db/create_dbuser_psql.sh.erb"
  user "go"
  group "go"
  mode "755"
end
