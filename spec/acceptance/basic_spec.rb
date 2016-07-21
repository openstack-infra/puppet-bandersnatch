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

  describe 'required services' do
    # Wait for bandersnatch to run
    describe command('sleep 480 && curl localhost') do
      its(:stdout) { should contain('Index of /') }
      its(:stdout) { should contain('simple/') }
    end

    describe command('curl localhost/robots.txt') do
      its(:stdout) { should match 'User-agent: *' }
      its(:stdout) { should match 'Disallow: /' }
    end
  end
end
