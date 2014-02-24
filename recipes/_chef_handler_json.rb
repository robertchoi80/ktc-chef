#
# setup json chef handler
#

include_recipe 'chef_handler'

directory '/var/chef/reports' do
  recursive true
end

args = [
  path: '/var/chef/reports'
]

chef_handler 'Chef::Handler::JsonFile' do
  source 'chef/handler/json_file'
  arguments args
  action :nothing
end.run_action(:enable)
