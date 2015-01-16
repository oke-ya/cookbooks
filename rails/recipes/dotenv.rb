require 'shellwords'
node[:deploy].each do |application, deploy|
  rails_env = deploy[:rails_env]
  
  template "#{deploy[:deploy_to]}/shared/.env" do
    source 'dotenv.erb'
    mode '0644'
    variables(:env => deploy[:app_env])
  end
end
