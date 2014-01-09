include_recipe "github::api"

node['deploy'].each do |application, deploy|
  auth_file_path = deploy['home'] + "/.ssh/authorized_keys"

  ruby_block "get_keys" do
    block do
      require 'rest-client'
      token = node['github']['token']
      header = {'Authorization' => "token #{token}"}
      uri = URI.parse("https://api.github.com/repos/#{node.default['repo_path']}/collaborators")
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        require 'net/https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        store = OpenSSL::X509::Store.new
        store.set_default_paths
        http.cert_store = store
      end
      body = nil
      header["User-Agent"] ||= 'Ruby1.8.7 net/http'
      http.start {
        req = Net::HTTP::Get.new(uri.request_uri, header)
        http.request(req) {|response|
          body = response.body
        }
      }
      key_urls = JSON.parse(body).map{|j| j['html_url'] + ".keys"}

      keys = key_urls.map{|url| RestClient.get(url).split(/\n/).first }
      keys += IO.read(auth_file_path).split(/\n/) if File.exists?(auth_file_path)
      keys.compact!
      keys.reject!{|key| key =~ /^\s*$/}
      keys.uniq!
      node.default["pub_key_file_content"] = keys.join("\n")
    end
    action :nothing
    subscribes :create, "gem_package[rest-client]"
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
