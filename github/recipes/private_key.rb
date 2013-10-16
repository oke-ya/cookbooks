node['deploy'].each do |application, deploy|
  ssh_dir = deploy[:home] + '/.ssh'
  private_key_path = "#{ssh_dir}/id_rsa"

  directory ssh_dir do
    mode   '0700'
    owner deploy[:user]
    group deploy[:group]
  end

  template "#{ssh_dir}/config" do
    source "ssh_config.erb"
    mode 0600
    owner deploy[:user]
    group deploy[:group]
  end

  execute "generate ssh keys for #{deploy[:user]}." do
    command %|ssh-keygen -t rsa -q -f #{private_key_path} -P ""; chown #{deploy[:user]}:#{deploy[:group]} #{private_key_path}; chown #{deploy[:user]}:#{deploy[:group]} #{private_key_path}.pub|
    not_if { ::File.exists?(private_key_path) }
  end

  oauth_file_path = "/tmp/oauth_token"

  cookbook_file oauth_file_path do
    source "github_token.txt"
  end

  repo_path = deploy['scm']["repository"].split(':').last.gsub(/\.git$/, '')

  gem_package "rest-client" do
    action :install
  end

  ruby_block 'sent private key' do
    block do
      require 'rest_client'
      token = File.read(oauth_file_path)
      hostname = `hostname`.chop
      key = File.read(private_key_path + '.pub').chop
      begin
        RestClient.post("https://api.github.com/repos/#{repo_path}/keys",
                        {'title' => hostname,
                         'key'   => key}.to_json,
                        {'Authorization' => "token #{token}"})
      rescue RestClient::UnprocessableEntity
      end
    end
  end
end
