include_recipe "teamcity::server"
include_recipe "teamcity-ci::_common"

node.override["datadog"]["tags"].push("teamcity")
process_check "teamcity" do
  process node["monitoring"]["processes"]
end
