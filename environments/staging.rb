name 'staging'
description 'staging environment file'

override_attributes(

  "ecom-platform" => {
    "cname" =>'ecom-platform-staging.frankross.in',
    "environment_variables" => {
      :SECRET_KEY_BASE =>'d731f261415e6f13e3e3e5a6726ee163707938f38514331fc2a67eda3800dd428bfe2a0c3b4ed83cf99e7df643e93b450511f81e05556712128ae786559ad',
      :AWS_ACCESS_KEY_ID=>"AKIAJXRZBPR2WQB6A7GA",
      :AWS_SECRET_ACCESS_KEY=>"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",
      :AWS_S3_BUCKET_NAME=>"ecom-platform-assets",
      :MANDRILLAPP_USERNAME=>"aakash@c42.in",
      :MANDRILLAPP_PASSWORD=>"yiQe1rK4ZC3ZYgz887oE1g",
      :CIRCLE_ARTIFACTS=>true,
      :ALGOLIA_APPLICATION_ID=>"T63QHGRW33",
      :ALGOLIA_ADMIN_API_KEY=>"8c5890a0d819b0043c688f23db75b573",
      :ALGOLIA_SEARCH_API_KEY=>"483dd0e5c6d5165b830187abcad40394",
      :ALGOLIA_SEARCH_INDEX_SUFFIX=>"staging_1_"
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
        cname:'ecom-platform-staging.frankross.in'
      },
      {
        name: 'ecom-docs',
        cname:'ecom-docs-staging.frankross.in'
      }
    ]
  },
)
