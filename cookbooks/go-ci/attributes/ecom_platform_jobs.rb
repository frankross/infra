def application_pipeline app,github_url
  {
    name: app,
    vcs_root: github_url,
    vcs_branch: "master",
    :stages => [{
      name: "specs",
      jobs:[{
        name: "bundle_install",
        tasks:[{command: "bundle",arguments: "install"}]},
      {
        name: "copy-database-file",
        tasks:[{command: "cp",arguments: "config/database.yml.ci config/database.yml"}]},
      {
        name: "db_setup",
        env_variable: [{"name" =>"RAILS_ENV","value" => 'test'}],
        tasks:[{command: "bundle",arguments: "exec rake db:create db:migrate db:schema:load"}]},
      {
        name: "spec",
        env_variable: [{"name" =>"RAILS_ENV","value" => "test"}],
        tasks:[{command: "bundle",arguments: "exec rspec"}]}
    ]
    },
    {
      name: "specs",
      jobs:[{
        name: "bundle_install",
        tasks:[{command: "bundle",arguments: "install"}]},
      {
        name: "copy-database-file",
        tasks:[{command: "cp",arguments: "config/database.yml.ci config/database.yml"}]},
      {
        name: "db_setup",
        env_variable: [{"name" =>"RAILS_ENV","value" => 'test'}],
        tasks:[{command: "bundle",arguments: "exec rake db:create db:migrate db:schema:load"}]},
      {
        name: "spec",
        env_variable: [{"name" =>"RAILS_ENV","value" => "test"}],
        tasks:[{command: "bundle",arguments: "exec rspec"}]}
    ]
  }]
  }
end

node.set["ci"]["jobs"]=[(application_pipeline "ecom","git@github.com:frankross/ecom-platform.git")]
