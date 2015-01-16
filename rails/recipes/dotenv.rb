# https://github.com/mikamai/opsworks-dotenv

require 'shellwords'
require 'yaml'
node[:deploy].each do |application, deploy|
  rails_env = deploy[:rails_env]

  Chef::Log.info("Generating dotenv for app: #{application} with env: #{rails_env}...")

  open("#{deploy[:deploy_to]}/shared/.env", 'w') do |f|
    deploy[:app_env].to_h.each do |name, value|
      f.puts "#{name}=#{value.to_s.shellescape}"
    end
  end
end
