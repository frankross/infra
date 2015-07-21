include_recipe "teamcity-ci::_common"
include_recipe "teamcity::server"

node.override["datadog"]["tags"].push("teamcity")
process_check "teamcity" do
  process node["monitoring"]["processes"]
end
