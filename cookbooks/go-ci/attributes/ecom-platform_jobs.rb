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
                 {command: "cp",arguments: "config/database.yml.ci\nconfig/database.yml",run_if: "passed"},
                 {command: "bundle",arguments: "exec\nrake\ndb:create\ndb:migrate\ndb:schema:load",run_if: "passed"},
                 {command: "bundle",arguments: "exec\nrspec",run_if: "passed"}]
        }]
      },
      {
        name: "staging-deploy",
        jobs:[{
          name: "staging",
          env_variable: [{"name" =>"RAILS_ENV","value" => 'test'}],
          tasks:[{command: "bundle",arguments: "install"},
                 {command: "knife",arguments: "ssh\nchef_environment:staging AND recipe:ecom-platform*\nsudo chef-client\n-x goserver\n-a ipaddress\n--no-host-key-verify"}]
        }]
      }]
    }]
  }
end

default["ci"]["jobs"]     = [(application_pipeline_group "ecom-platform","ecom-platform:frankross/ecom-platform.git")]
