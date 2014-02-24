# vim: ft=sh:

@test "reports directory created" {
  [[ -d /var/chef/reports ]]
}

@test "json data file created within the reports directory" {
  f=`find /var/chef/reports/ -name "*.json" | wc -w`
  [[ $f -gt 0 ]]
}
