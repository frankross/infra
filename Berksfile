source "http://api.berkshelf.com"
cookbook 'go', git: 'https://github.com/ThoughtWorksInc/go-cookbook.git'
cookbook 'teamcity', git: 'https://github.com/hschaeidt/teamcity-cookbook.git'
cookbook 'memcached', git: 'https://github.com/opscode-cookbooks/memcached.git'
cookbooks_path = File.expand_path('../cookbooks', __FILE__)
Dir["#{cookbooks_path}/**"].each do |cookbook_path|
    cookbook File.basename(cookbook_path), path: cookbook_path
end
