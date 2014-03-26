#
# setup chef sensu handler
#

include_recipe 'chef_handler'
include_recipe 'services'

gem_packages = {
  'oj' => '2.0.9',
  'amq-protocol' => '1.2.0',
  'amq-client' => '1.0.2',
  'amqp' => '1.0.0'
}

ep = Services::Endpoint.new 'sensu-rabbitmq'
ep.load

Chef::Log.info("rabbit host: #{ep.ip}")
Chef::Log.info("rabbit port: #{ep.port}")

# This is needed for compiling Oj native extension.
# Would be used until we have pre-compiled Oj package.
package 'build-essential'

gem_packages.each do |pkg, ver|
  chef_gem pkg do
    version ver
    action :nothing
    subscribes :install, 'package[build-essential]', :immediately
  end
end

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
  action :create
end

cookbook_file "#{node['chef_handler']['handler_path']}/sensu_handler.rb" do
  source 'sensu_handler.rb'
  mode 0640
  action :create
end

chef_handler 'Chef::Handler::Sensu::ReportSensu' do
  source "#{node['chef_handler']['handler_path']}/sensu_handler.rb"
  arguments args
  action :enable
end
