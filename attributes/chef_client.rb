# Chef-client tuning

include_attribute 'chef-client'

default[:chef_client][:splay] = '300'
default[:chef_client][:interval] = '300'

default[:chef_client][:cron][:use_cron_d] = true
default[:chef_client][:cron][:hour] = '*'
default[:chef_client][:cron][:log_file] = '/var/log/chef/client_cron.log'
default[:chef_client][:cron][:minute] = '*/15'
default[:chef_client][:log_file] = '/var/log/chef/client.log'

# This is for calculating sensu_handler report interval
# Refer to the above node[:chef_client][:cron] and derive from it.
# Eg) If the 'minute' is '*/15', then [:cron][:interval] should be 15.
default[:chef_client][:cron][:interval] = 15
