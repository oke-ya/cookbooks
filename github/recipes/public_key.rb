include_recipe "github::api"

node['deploy'].each do |application, deploy|
  auth_file_path = deploy['home'] + "/.ssh/authorized_keys"

  ruby_block "get_keys" do
    block do
      token = File.read(node.default['oauth_file_path'])
      key_urls = JSON.parse(RestClient.get("https://api.github.com/repos/#{node.default['repo_path']}/collaborators", {'Authorization' => "token #{token}"})).map{|j| j['html_url'] + ".keys"}
      keys = key_urls.map{|url| RestClient.get(url).split(/\n/).first }
      keys += IO.read(auth_file_path).split(/\n/)
      keys.compact!
      keys.reject!{|key| key =~ /^\s*$/}
      node.default["pub_key_file_content"] = keys.join("\n")
    end
    subscribes :create, resources("cookbook_file[/tmp/oauth_token]")
    action :nothing
  end

  file auth_file_path do
    resources("ruby_block[get_keys]").run_action(:run)
    content node.default["pub_key_file_content"]
  end
end
