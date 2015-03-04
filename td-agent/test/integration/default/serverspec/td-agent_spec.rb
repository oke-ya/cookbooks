require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/usr/lib/fluent/ruby/bin:/sbin:/usr/sbin'
  end
end

describe package('td-agent') do
  it { should be_installed }
end

describe service('td-agent') do
  it { should be_running }
end

describe file('/etc/td-agent') do
  it { should be_a_directory }
end

describe file('/etc/td-agent/td-agent.conf') do
  it { should be_a_file }
  it { should be_mode 644 }
end

describe file('/etc/td-agent/conf.d') do
  it { should be_a_directory }
  it { should be_mode 755 }
end

describe package('fluent-plugin-time_parser') do
  it { should_not be_installed.by('gem') }
end
