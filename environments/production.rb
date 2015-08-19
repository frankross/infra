name 'production'
description 'production environment file'

cookbook_versions ({
  'base'                => '= 0.0.6',
  'ecom-platform'       => '= 0.1.16',
  'ecom-docs'           => '= 0.1.5',
  'library'             => '= 0.0.22',
  'proxy'               => '= 0.1.9'
})

override_attributes(

  "ecom-platform" => {
    "cname" =>'www.frankross.in',
    "environment_variables" => {
      :AWS_S3_BUCKET_NAME=>"ecom-platform-assets",
      :CIRCLE_ARTIFACTS=>true,
      :NEW_RELIC_AGENT_ENABLED => true
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
      }
    ]
  },
)
