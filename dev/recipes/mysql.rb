package "mysql-client"
package "mysql-server"
package "libmysql++-dev"

template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  notifies :run, 'execute[restart_mysql]', :immediately
end

execute "restart_mysql" do
  command "service mysql restart"
  action :nothing
end
