# configure chef client

%w/
  omnibus_updater
  chef-client::cron
/.each do |recipe|
  include_recipe recipe
end

node['kt']['report_handlers'].each do |h|
  include_recipe "ktc-chef::_chef_handler_#{h}"
end
