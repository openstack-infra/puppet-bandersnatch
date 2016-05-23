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

  describe 'required services' do
    describe command('curl localhost') do
      its(:stdout) { should contain('Index of /') }
      its(:stdout) { should contain('centos/') }
      its(:stdout) { should contain('ceph-deb-hammer/') }
      its(:stdout) { should contain('epel/') }
      its(:stdout) { should contain('npm/') }
      its(:stdout) { should contain('pypi/') }
      its(:stdout) { should contain('ubuntu/') }
      its(:stdout) { should contain('wheel/') }
    end

    describe command('curl localhost/robots.txt') do
      its(:content) { should match 'User-agent: \*' }
      its(:content) { should match 'Disallow: /' }
    end
  end
end
