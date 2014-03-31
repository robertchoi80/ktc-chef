# configure chef client

%w(
  chef-client::cron
).each do |recipe|
  include_recipe recipe
end

# ensure cron is running
service 'cron' do
  action :start
end

node['kt']['report_handlers'].each do |h|
  include_recipe "ktc-chef::_chef_handler_#{h}"
end
