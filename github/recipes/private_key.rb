node['deploy'].each do |application, deploy|

  node.default['repo_path'] = deploy['scm']["repository"].split(':').last.gsub(/\.git$/, '')

  gem_package "rest-client" do
    action :install
  end

  ssh_dir = deploy[:home] + '/.ssh'
  private_key_path = "#{ssh_dir}/id_rsa"

  user deploy[:user] do
    action :create
    home deploy[:home]
    shell "/bin/bash"
  end

  directory deploy[:home] do
    action :create
    user deploy[:user]
    group deploy[:user]
  end

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
    variables deploy: deploy
  end

  execute "generate ssh keys for #{deploy[:user]}." do
    command %|ssh-keygen -t rsa -q -f #{private_key_path} -P ""; chown #{deploy[:user]}:#{deploy[:group]} #{private_key_path}; chown #{deploy[:user]}:#{deploy[:group]} #{private_key_path}.pub|
    not_if { ::File.exists?(private_key_path) }
  end

  ruby_block 'sent private key' do
    block do
      require 'rest_client'
      token = node["github"]["token"]
      hostname = `hostname`.chop
      key = File.read(private_key_path + '.pub').chop
      begin
        RestClient.post("https://api.github.com/repos/#{node.default['repo_path']}/keys",
                        {'title' => hostname,
                         'key'   => key}.to_json,
                        {'Authorization' => "token #{token}"})
      rescue RestClient::UnprocessableEntity
      end
    end
  end
end
