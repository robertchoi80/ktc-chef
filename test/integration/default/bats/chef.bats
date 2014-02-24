# vim: ft=sh:

@test "chef cron created" {
  [[ -f /etc/cron.d/chef-client ]]
}
