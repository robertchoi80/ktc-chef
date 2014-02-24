# Encoding: UTF-8
#
#  Controll omni updater recipe
#

include_attribute 'ktc-package'
include_attribute 'omnibus_updater'

default['omnibus_updater']['cache_dir'] = Chef::Config[:file_cache_path]
default['omnibus_updater']['cache_omnibus_installer'] = true
default['omnibus_updater']['direct_url'] = "http://#{node["repo_host"]}/prod/chef-client.deb"
default['omnibus_updater']['kill_chef_on_upgrade'] = false
