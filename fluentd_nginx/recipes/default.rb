# -*- coding: utf-8 -*-
include_recipe "td_agent"

node[:deploy].each do |application, deploy|
  template "/etc/td-agent/conf.d/#{application}" do
    source "sites.conf.erb"
    mode 644
    owner "root"
    group "root"

    s3 = node[:s3]
    variables(application:  application,
              aws_key_id:   s3[:access_key],
              aws_sec_key:  s3[:access_secret],
              s3_bucket:    s3[:bucket],
              s3_end_point: s3[:end_point])
    notifies :restart, "service[td-agent]"
  end
end