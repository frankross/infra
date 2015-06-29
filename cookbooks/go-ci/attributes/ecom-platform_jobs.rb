def application_pipeline_group app,github_url
  {
    name: app,
    pipelines: [{
        name: app,
        vcs_root: github_url,
        vcs_branch: "master",
        :stages => [{
          name: "specs",
          jobs:[{
            name: "specs",
            env_variable: [{"name" =>"RAILS_ENV","value" => 'test'}],
            tasks:[{command: "bundle",arguments: "install"},
                   {command: "cp",arguments: "config/database.yml.ci config/database.yml",run_if: "passed"},
                   {command: "bundle",arguments: "exec rake db:create db:migrate db:schema:load",run_if: "passed"},
                   {command: "bundle",arguments: "exec rspec",run_if: "passed"}]
          }]
        }]
    }]
  }
end

default["ci"]["jobs"]     = [(application_pipeline_group "ecom-platform","ecom-platform:frankross/ecom-platform.git")]
