node.from_file( run_context.resolve_attribute('postgresql', 'default') )
include_recipe "postgresql::client"
include_recipe "postgresql::server"
include_recipe "postgresql::contrib"
