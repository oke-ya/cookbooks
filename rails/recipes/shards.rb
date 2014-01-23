node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/shards.yml" do
    source "shards.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    environments = ['development', 'production'].tap{|_| _ << deploy[:rails_env] }
    environments = environments.select{|_| _ && _.length > 0}

    variables(:database      => deploy[:database],
              :read_replicas => deploy[:read_replicas],
              :environments  => environments)

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end
