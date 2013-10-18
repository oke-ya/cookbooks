node['deploy'].each do |application, deploy|
  package 'nginx' do
    action :install
  end

  file "/etc/nginx/sites-enabled/default" do
    action :delete
  end

  template "/etc/nginx/sites-available/#{application}" do
    action :create
    owner 'root'
    group 'root'
    mode '0644'
    source "nginx.conf.erb"
    variables application: application
  end

  file "/etc/nginx/sites-enabled/000-default" do
    action :delete
  end

  link "/etc/nginx/sites-enabled/#{application}" do
    action :create
    to "/etc/nginx/sites-available/#{application}"
    notifies :run, "execute[restart_nginx]", :immediately
  end

  execute "restart_nginx" do
    command "service nginx restart"
  end
end
