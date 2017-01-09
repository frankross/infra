name 'production'
description 'production environment file'

cookbook_versions ({
  'base'                => '= 1.0.0',
  'ecom-platform'       => '= 1.1.9',
  'ecom-web'            => '= 1.0.0',
  'ecom-docs'           => '= 0.1.8',
  'emr'                 => '= 0.1.8',
  'library'             => '= 1.0.5',
  'proxy'               => '= 1.0.0',
  'sensu_client'        => '= 0.2.0'

})

override_attributes(

  "ecom-platform" => {
    "vcs_branch" => "production",
    "cname" =>'www.frankross.in',
    "environment_variables" => {
      :APP_NAME => "'EFR e-Com (production)'",
      :AWS_S3_BUCKET_NAME=>"emami-production-2",
      :CIRCLE_ARTIFACTS=>true,
      :NEW_RELIC_AGENT_ENABLED => false,
      :DOMAIN => "http://www.frankross.in"
    }
  },
  "emr" => {
    "vcs_branch" => "production",
    "cname" =>'emr.frankross.in',
    "environment_variables" => {
    }
  },
  "ecom-docs" => {
    "cname" =>'ecom-docs.frankross.in',
    "environment_variables" => {
      :SECRET_KEY_BASE =>'aacaea4f251731969a3d4623d36eb9d7bf908683c00479bab517831e6452889a15576a60d3f406b1af6a5016f3290c7a2c9f12adbb1b80817eb8825bbc1d2a23',
    }
  },
  "ecom-web" => {
    "vcs_branch" => "uat",
    "environment_variables" => {
      :NEW_RELIC_AGENT_ENABLED => false
    }
  },
  :proxy => {
    :aws => {
      :eip=>'52.74.97.11'
    },
    :frontend_servers => [
      {
        name: 'ecom-platform',
        cname:'www.frankross.in'
      },
      {
        name: 'ecom-docs',
        cname:'ecom-docs.frankross.in'
      },
      {
        name: 'emr',
        cname:'emr.frankross.in'
      }
    ]
  },
)
