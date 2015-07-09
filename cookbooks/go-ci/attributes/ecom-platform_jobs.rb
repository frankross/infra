def staging_deploy app
  {
    name: "staging-deploy",
    jobs:[{
      name: "staging",
      env_variable: [{"name" =>"RAILS_ENV","value" => 'staging'}],
      tasks:[{command: "bundle",arguments: "install"},
             {command: "knife",arguments: "ssh\nchef_environment:staging AND recipe:#{app}\\:\\:app\nsudo chef-client\n-x goserver\n-a ipaddress\n--no-host-key-verify"}]
    }]
  }
end

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
                 {command: "bundle",arguments: "exec\nrake\nspec",run_if: "passed"},
                 {command: "aws",arguments: "s3\nsync\n./doc/api/v1/\ns3://ecom-docs",run_if: "passed"}]
        }]
      },
      (staging_deploy app)
      ]
    },
    {
      name: "#{app}-specs-all-branches",
      vcs_root: github_url,
      vcs_branch: "allbranches",
      :stages => [{
        name: "specs",
        jobs:[{
          name: "specs",
          env_variable: [{"name" =>"RAILS_ENV","value" => 'test'}],
          tasks:[{command: "bundle",arguments: "install"},
                 {command: "cp",arguments: "config/database.yml.ci\nconfig/database.yml",run_if: "passed"},
                 {command: "bundle",arguments: "exec\nrake\ndb:create\ndb:migrate\ndb:schema:load",run_if: "passed"},
                 {command: "bundle",arguments: "exec\nrake\nspec",run_if: "passed"}]
      }]
      }]
    }
    ]}
end

default["ci"]["jobs"]= [
  (application_pipeline_group "ecom-platform","ecom-platform:frankross/ecom-platform.git"),
 {
   name: "ecom-docs",
   pipelines: [{
     name: "ecom-docs",
     vcs_root: "ecom-docs:frankross/ecom-docs.git",
     vcs_branch: "master",
     :stages => [(staging_deploy "ecom-docs")]
   }]
 }
 ]
