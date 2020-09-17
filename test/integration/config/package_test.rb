# Inspec test for recipe syslog_ng_test::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('syslog-ng') do
  it { should be_installed }
end

describe service('syslog-ng') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe directory('/etc/syslog-ng') do
  it { should exist }
end

describe file('/etc/syslog-ng/syslog-ng.conf') do
  it { should exist }
  its('type') { should cmp 'file' }
  it { should be_file }
  it { should_not be_directory }
end

%w(conf.d destination.d filter.d log.d parser.d rewrite.d source.d template.d).each do |conf_dir|
  describe directory("/etc/syslog-ng/#{conf_dir}") do
    it { should exist }
  end
end

describe file('/etc/yum.repos.d/syslog-ng312.repo') do
  it { should_not exist }
end
