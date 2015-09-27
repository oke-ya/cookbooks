include_recipe 'nginx'

pkgs = %w(nginx nginx-common nginx-full)

apt_repository 'nginx' do
  uri          'http://ppa.launchpad.net/nginx/stable/ubuntu'
  distribution node['lsb']['codename']
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'C300EE8C'
  deb_src      true
  pkgs.map{|name| "package[#{name}]"}.each do |pkg|
    notifies :upgrade, pkg
  end
  notifies :create, "directory[/var/log/nginx]"
end

pkgs.each do |pkg|
  package pkg do
    ignore_failure true
    action :nothing
    options '-o Dpkg::Options::="--force-confold"'
    notifies :restart, "service[nginx]"
  end
end
