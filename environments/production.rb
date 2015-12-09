name 'production'
description 'production environment file'

cookbook_versions ({
  'base'                => '= 0.0.7',
  'ecom-platform'       => '= 0.1.28',
  'ecom-docs'           => '= 0.1.7',
  'emr'                 => '= 0.1.5',
  'library'             => '= 0.0.39',
  'proxy'               => '= 0.1.11'
})

override_attributes(

  "ecom-platform" => {
    "vcs_branch" => "production",
    "cname" =>'www.frankross.in',
    "environment_variables" => {
      :APP_NAME => "'EFR e-Com (production)'",
      :AWS_S3_BUCKET_NAME=>"emami-production",
      :CIRCLE_ARTIFACTS=>true,
      :NEW_RELIC_AGENT_ENABLED => true
    }
  },
  "emr" => {
    "vcs_branch" => "master",
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
  :proxy => {
    :aws => {
      :eip=>'54.169.231.10'
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
