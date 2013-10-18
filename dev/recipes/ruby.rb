ruby_version = node['ruby']['version']
['libreadline-dev', 'zlib1g-dev', 'libssl-dev', 'libyaml-dev'].each do |depends|
  package depends do
    action :install
  end
end

['libc6', 'autoconf', 'gcc', 'make'].each do |dev_tool|
  package dev_tool do
    action :install
  end
end

archive_path = "/usr/local/src/ruby-#{ruby_version}.tar.bz2"
remote_file archive_path do
  source "http://core.ring.gr.jp/pub/lang/ruby/ruby-#{ruby_version}.tar.bz2"
  action :create_if_missing
  mode 0644
end

bash 'install' do
  cwd ::File.dirname(archive_path)
  code <<-EOH
    tar xf #{archive_path}
    cd #{File.basename(archive_path, '.tar.bz2')}
    ./configure --disable-install-doc --disable-install-rdoc --disable-install-capi  > /dev/null 2>&1
    make         > /dev/null 2>&1
    make install > /dev/null 2>&1
  EOH
  not_if %(ruby -v | awk '$2 != "#{ruby_version.gsub("-", "")}" {exit 1}')
end

gem_package "bundler"
package 'libxml2-dev'
package "libxslt1-dev"
package "libev-dev"
package "g++"
