include_recipe 'nginx'

apt_repository 'nginx' do
  uri          'http://ppa.launchpad.net/nginx/stable/ubuntu'
  distribution node['lsb']['codename']
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'C300EE8C'
  deb_src      true
  notifies :install, "package[nginx]"
end
