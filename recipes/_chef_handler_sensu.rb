#
# setup chef sensu handler
#

include_recipe 'chef_handler'
include_recipe 'services'

ep = Services::Endpoint.new 'sensu-rabbitmq'
ep.load

Chef::Log.info("rabbit host: #{ep.ip}")
Chef::Log.info("rabbit port: #{ep.port}")

gem_packages = { 'oj' => '2.0.9', 'amq-protocol' => '1.2.0', 'amq-client' => '1.0.2', 'amqp' => '1.0.0' }

gem_packages.each do |pkg, ver|
  gem_package pkg do
    gem_binary "/opt/chef/embedded/bin/gem"
    version ver
    action :nothing
  end.run_action(:install)
end

#gem_package "oj" do
#  gem_binary "/opt/chef/embedded/bin/gem"
#  version '2.0.9'
#  action :nothing
#end.run_action(:install)
#
#gem_package "amq-protocol" do
#  gem_binary "/opt/chef/embedded/bin/gem"
#  version '1.2.0'
#  action :nothing
#end.run_action(:install)
#
#gem_package "amq-client" do
#  gem_binary "/opt/chef/embedded/bin/gem"
#  version '1.0.2'
#  action :nothing
#end.run_action(:install)
#
#gem_package "amqp" do
#  gem_binary "/opt/chef/embedded/bin/gem"
#  version '1.0.0'
#  action :nothing
#end.run_action(:install)

args = []
if node['kitchen']
  args = [
    rabbit_host: 'localhost',
    rabbit_port: 5671,
    config_file: '/etc/sensu/config.json'
  ]
else
  args = [
    rabbit_host: ep.ip,
    rabbit_port: ep.port.to_i,
    config_file: '/etc/sensu/config.json'
  ]
end

cookbook_file "#{node['chef_handler']['handler_path']}/_rabbitmq.rb" do
  source 'rabbitmq.rb'
  mode 0640
  action :nothing
end.run_action(:create)

cookbook_file "#{node['chef_handler']['handler_path']}/sensu_handler.rb" do
  source 'sensu_handler.rb'
  mode 0640
  action :nothing
end.run_action(:create)

chef_handler 'Chef::Handler::Sensu::ReportSensu' do
  source "#{node['chef_handler']['handler_path']}/sensu_handler.rb"
  arguments args
  action :nothing
end.run_action(:enable)
