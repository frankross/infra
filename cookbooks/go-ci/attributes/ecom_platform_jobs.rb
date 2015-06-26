def application_pipeline app,github_url
  {
    name: app,
    vcs_root: github_url,
    vcs_branch: "*/master",
    :stages => [{
      name: "specs",
      jobs:[{
        name: "bundle_install",
        tasks:[{
          command: "bundle",
          arguments: "install"
        }]
      },
      {
        name: "db_setup",
        env_variable: [{"name" =>"RAILS_ENV","value" => "test"}],
        tasks:[{
          command: "bundle",
          arguments: "bundle exec rake db:create db:schema:load --trace"
        }]
      },
      {
        name: "spec",
        tasks:[{
          command: "bundle",
          arguments: "exec rspec"
        }]
      }
    ]
  }]
  }
end

node.set["ci"]["jobs"]=[(application_pipeline "hari","https://github.com/hogaur/rails-blog.git")]
