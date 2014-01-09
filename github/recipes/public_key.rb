require 'open-uri'
include_recipe "github::api"

node['deploy'].each do |application, deploy|
  auth_file_path = deploy['home'] + "/.ssh/authorized_keys"

  ruby_block "get_keys" do
    block do
      token = node['github']['token']
      key_urls = nil
      open("https://api.github.com/repos/#{node.default['repo_path']}/collaborators",  {'Authorization' => "token #{token}"}) do |io|
        key_urls = JSON.parse(io.read).map{|j| j['html_url'] + ".keys"}
      end
      keys = key_urls.map{|url|
        key = nil
        open(url) do |io|
          key = io.read.split(/\n/).first
        end
        key
      }
      keys += IO.read(auth_file_path).split(/\n/) if File.exists?(auth_file_path)
      keys.compact!
      keys.reject!{|key| key =~ /^\s*$/}
      keys.uniq!
      node.default["pub_key_file_content"] = keys.join("\n")
    end
    action :nothing
  end

  directory File.dirname(auth_file_path) do
    action :create
    mode   0600
    owner  (deploy[:user] || "root")
    group  (deploy[:user] || "root")
  end
  
  file auth_file_path do
    resources("ruby_block[get_keys]").run_action(:run)
    content node.default["pub_key_file_content"]
    subscribes :create, "directory[#{File.dirname(auth_file_path)}]"
  end
end
