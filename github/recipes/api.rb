node['deploy'].each do |application, deploy|
  node.default['oauth_file_path'] = "/tmp/oauth_token"
  cookbook_file node.default['oauth_file_path'] do
    source "github_token.txt"
  end

  node.default['repo_path'] = deploy['scm']["repository"].split(':').last.gsub(/\.git$/, '')

  gem_package "rest-client" do
    action :install
  end
end
