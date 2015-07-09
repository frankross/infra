search(:users, "groups:ci") do |user|
  htpasswd node.go.passwd.file_location do
    user user["id"]
    password user["passwd"]
    type "sha1"
  end
end

execute "chown -R go.go #{node.go.passwd.file_location}"
