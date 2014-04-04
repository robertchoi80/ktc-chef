return unless chef_environment.eql?('mkd2')

default['kt']['report_handlers'] = %w(
  json
  graphite
  hipchat
  sensu
)

default['kt']['report_interval'] = 2

# parameters to the hipchat report handler, order matters.
default['kt']['hipchat'] = {
  api_token: '598de357f0ae8d7f8f3556e0cf8347',
  room_name: 'chef_alerts',
  notify_users: false,
  report_success: false
}
