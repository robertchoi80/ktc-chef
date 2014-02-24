#
# setup hipchat chef handler
#
# https://github.com/hipchat/hipchat-rb/blob/master/lib/hipchat/chef.rb
#

include_recipe 'chef_handler'

chef_gem 'hipchat'

handler_gem = Gem::Specification.find_by_name('hipchat')
chef_handler 'HipChat::NotifyRoom' do
  source "#{handler_gem.lib_dirs_glob}/hipchat/chef.rb"
  arguments node['kt']['hipchat'].values
  action :nothing
end.run_action(:enable)
