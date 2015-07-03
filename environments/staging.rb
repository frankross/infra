name 'staging'
description 'staging environment file'

override_attributes(

  "ecom-platform" => {
    "cname" =>'frankross.c42.in',
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
  :proxy => {
    :aws => {
      :eip=>'52.74.183.24'
    },
    :frontend_servers => [
      {
        name: 'ecom-platform',
        cname:'frankross.c42.in'
      }
    ]
  },
)
