require 'spec_helper_acceptance'

describe cron('bandersnatch') do
  it { should have_entry('*/5 * * * * flock -n /var/run/bandersnatch/mirror.lock timeout -k 2m 30m run-bandersnatch >>/var/log/bandersnatch/mirror.log 2>\&1').with_user('root') }
end
