node['deploy'].each do |application, deploy|
  package 'git-core'

  directory "/home/#{deploy[:user]}/project" do
    action :create
    user  deploy[:user]
    group deploy[:group]
  end

  git "/home/#{deploy[:user]}/project/#{application}" do
    repository deploy[:scm][:repository]
    reference  deploy[:scm][:revision]
    user deploy[:user]
  end

  template "/home/#{deploy[:user]}/.bash_profile" do
    source "bash_profile"
    user deploy[:user]
    variables deploy: deploy
  end
end
