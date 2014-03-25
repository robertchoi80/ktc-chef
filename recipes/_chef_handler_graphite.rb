#
# setup graphite chef handler
#

include_recipe 'chef_handler'
include_recipe 'services'

chef_gem 'chef-handler-graphite'

ep = Services::Endpoint.new 'graphite'
ep.load
Chef::Log.info "Graphite service ip - #{ep.ip}"
Chef::Log.info "Graphite service port - #{ep.port}"

args = [
  metric_key: "chef.#{node['hostname']}",
  graphite_host: ep.ip,
  graphite_port: ep.port
]

handler_gem = Gem::Specification.find_by_name('chef-handler-graphite')
chef_handler 'GraphiteReporting' do
  source "#{handler_gem.lib_dirs_glob}/chef-handler-graphite.rb"
  arguments args
  action :nothing
end.run_action(:enable)
