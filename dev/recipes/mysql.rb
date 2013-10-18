package "mysql-client"
package "mysql-server"
package "libmysql++-dev"

template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
end
