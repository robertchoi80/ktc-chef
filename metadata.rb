name             'ktc-chef'
maintainer       'KT Cloudware'
maintainer_email 'wil.reichert@ktcloudware.com'
license          'All rights reserved'
description      'configure chef client'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.3'

%w(centos ubuntu).each do |os|
  supports os
end

depends 'chef-client'
depends 'chef_handler'
depends 'ktc-logging'
depends 'ktc-package'
depends 'logstash_handler'
depends 'omnibus_updater'
depends 'services'
