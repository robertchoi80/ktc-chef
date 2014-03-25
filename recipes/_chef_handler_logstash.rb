#
# setup logstash chef handler
#

include_recipe 'services'

ep = Services::Endpoint.new 'logstash-server'
ep.load
Chef::Log.info "Logstash service ip - #{ep.ip}"
Chef::Log.info "Logstash service port - #{ep.port}"

node.default['chef_client']['handler']['logstash']['host'] = ep.ip
node.default['chef_client']['handler']['logstash']['port'] = ep.port

include_recipe 'logstash_handler'
