name 'staging'
description 'staging environment file'

cookbook_versions ({
  'base'                => '= 0.0.9',
  'ecom-platform'       => '= 0.1.31',
  'ecom-docs'           => '= 0.1.7',
  'emr'                 => '= 0.1.5',
  'library'             => '= 0.0.39',
  'proxy'               => '= 0.1.12'
})

override_attributes(

  "ecom-platform" => {
    "vcs_branch" => "uat",
    "cname" =>'staging.frankross.in',
    "environment_variables" => {
      :APP_NAME => "'EFR e-Com (staging)'",
      :AWS_S3_BUCKET_NAME=>"emami-staging",
      :CIRCLE_ARTIFACTS=>true,
      :NEW_RELIC_AGENT_ENABLED => true
    }
  },
  "emr" => {
    "vcs_branch" => "master",
    "cname" =>'emr-staging.frankross.in',
    "environment_variables" => {
      :APP_NAME => "'EMR (staging)'"
    }
  },
  "ecom-docs" => {
    "cname" =>'ecom-docs-staging.frankross.in',
    "environment_variables" => {
      :SECRET_KEY_BASE =>'aacaea4f251731969a3d4623d36eb9d7bf908683c00479bab517831e6452889a15576a60d3f406b1af6a5016f3290c7a2c9f12adbb1b80817eb8825bbc1d2a23',
    }
  },
  :proxy => {
    :aws => {
      :eip=>'52.74.183.24'
    },
    :frontend_servers => [
      {
        name: 'ecom-platform',
        cname:'staging.frankross.in'
      },
      {
        name: 'ecom-docs',
        cname:'ecom-docs-staging.frankross.in'
      },
      {
        name: 'emr',
        cname:'emr-staging.frankross.in'
      }
    ]
  },
)
