require 'spec_helper_acceptance'

describe 'operating system packages' do
  describe package('apache2'), :if => ['debian', 'ubuntu'].include?(os[:family]) do
    it { should be_installed }
  end

  describe package('httpd'), :if => ['centos', 'redhat'].include?(os[:family]) do
    it { should be_installed }
  end
end


describe 'pip packages' do
  packages = [
    package('bandersnatch'),
  ]

  packages.each do |package|
    describe package do
      it { should be_installed.by('pip') }
    end
  end
end
