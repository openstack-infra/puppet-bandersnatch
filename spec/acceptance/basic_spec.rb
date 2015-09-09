require 'spec_helper_acceptance'

describe 'puppet-bandersnatch module' do
  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures')
  end

  def preconditions_puppet_module
    module_path = File.join(pp_path, 'preconditions.pp')
    File.read(module_path)
  end

  def default_puppet_module
    module_path = File.join(pp_path, 'default.pp')
    File.read(module_path)
  end

  before(:all) do
    apply_manifest(preconditions_puppet_module, catch_failures: true)
  end

  it 'should work with no errors' do
    apply_manifest(default_puppet_module, catch_failures: true)
  end

  it 'should be idempotent', :if => ['debian', 'ubuntu'].include?(os[:family]) do
    apply_manifest(default_puppet_module, catch_changes: true)
  end

  it 'should be idempotent', :if => ['fedora', 'redhat'].include?(os[:family]) do
    pending('this module is not idempotent on CentOS yet')
    apply_manifest(default_puppet_module, catch_changes: true)
  end

  describe cron do
    it { should have_entry('*/5 * * * * flock -n /var/run/bandersnatch/mirror.lock timeout -k 2m 30m run-bandersnatch >>/var/log/bandersnatch/mirror.log 2>\&1').with_user('root') }
  end

  describe 'files and directories' do
    describe file('/var/log/bandersnatch') do
      it { should be_directory }
    end

    describe file('/var/run/bandersnatch') do
      it { should be_directory }
    end

    describe file('/usr/local/bin/run-bandersnatch') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match 'if __name__ == \'__main__\':' }
    end

    describe file('/srv/static/mirror/web/robots.txt') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match 'User-agent: \*' }
      its(:content) { should match 'Disallow: /' }
    end

    describe file('/etc/bandersnatch.conf') do
      it { should be_file }
      its(:content) { should match '[mirror]' }
      its(:content) { should match 'directory = /srv/static/mirror' }
    end

    describe file('/srv/static') do
      it { should be_directory }
    end

    describe 'directories belonging to root user and group' do
      directories = [
        file('/srv/static/mirror'),
        file('/srv/static/mirror/web'),
      ]

      directories.each do |dir|
        describe dir do
          it { should be_directory }
          it { should be_owned_by 'root'}
          it { should be_grouped_into 'root'}
        end
      end
    end
  end

  describe 'required packages' do
    packages = [
      package('bandersnatch'),
    ]

    packages.each do |package|
      describe package do
        it { should be_installed.by('pip') }
      end
    end
  end

  describe 'required services' do
    describe port(80) do
      it { should be_listening }
    end

    describe command("curl localhost") do
      its(:stdout) { should contain('Index of /') }
    end
  end
end
