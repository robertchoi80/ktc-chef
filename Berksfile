#
# vim: set ft=ruby:
#
chef_api "https://cookbooks.mkd2.ktc", node_name: "cookbook", client_key: ".cookbook.pem"

site :opscode

metadata

group "integration" do
  cookbook "ktc-testing"
  cookbook "ktc-package", "= 0.1.20"
  cookbook "etcd"
  cookbook "ktc-graphite"
  cookbook "ktc-sensu"
end
