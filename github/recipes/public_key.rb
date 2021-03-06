require "open-uri"

node['deploy'].each do |application, deploy|
  auth_file_path = deploy['home'] + "/.ssh/authorized_keys"

  ruby_block "get_keys" do
    block do
      token = node['github']['token']
      header = {'Authorization' => "token #{token}"}
      repo_path = deploy['scm']["repository"].split(':').last.gsub(/\.git$/, '')
      uri = URI.parse("https://api.github.com/repos/#{repo_path}/collaborators")
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
      keys = key_urls.map{|url|
        body = nil
        open(url) do |f|
          body = f.read.chomp
        end
        body.chomp.split(/\n/)
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
    mode   0700
    owner  (deploy[:user] || "root")
  end
  
  file auth_file_path do
    resources("ruby_block[get_keys]").run_action(:run)
    content node.default["pub_key_file_content"]
    owner deploy[:user]
    subscribes :create, "directory[#{File.dirname(auth_file_path)}]"
  end
end
