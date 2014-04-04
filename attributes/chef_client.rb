# Chef-client tuning

include_attribute 'chef-client'

default[:chef_client][:splay] = '300'
default[:chef_client][:interval] = '300'

default[:chef_client][:cron][:use_cron_d] = true
default[:chef_client][:cron][:hour] = '*'
default[:chef_client][:cron][:log_file] = '/var/log/chef/client_cron.log'
default[:chef_client][:cron][:minute] = '*/15'
default[:chef_client][:log_file] = '/var/log/chef/client.log'
