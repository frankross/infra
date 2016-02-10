# specify resource without action for testing default action == :install
sensu_gem 'sensu-plugins-sensu'

# explicitly specify :install action for additional tests
sensu_gem 'sensu-plugins-slack' do
  action :install
end

# ensure we pass the specified version
sensu_gem 'sensu-plugins-chef' do
  version '0.0.5'
  action :install
end

# for testing remove action
sensu_gem 'sensu-plugins-hipchat' do
  action :remove
end


