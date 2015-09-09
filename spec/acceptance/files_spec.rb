require 'spec_helper_acceptance'

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
