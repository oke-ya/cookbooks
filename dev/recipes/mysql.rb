package "mysql-client"
package "mysql-server"

template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
end
