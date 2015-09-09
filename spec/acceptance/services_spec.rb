require 'spec_helper_acceptance'

describe 'bandersnatch services' do
  describe service('apache2'), :if => ['debian', 'ubuntu'].include?(os[:family]) do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('httpd'), :if => ['centos', 'redhat'].include?(os[:family]) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(80) do
    it { should be_listening }
  end

  describe command("curl localhost") do
    its(:stdout) { should contain('Index of /') }
  end
end
