require 'spec_helper_acceptance'

describe 'curator jobs' do

  context 'install job' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'curator': }
      curator::job { 'test':
        command => 'replicas',
        host    => 'elasticsearch.company.org',
        count   => 4,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe cron() do
      it { should have_entry "10 1 * * * /bin/curator --logfile /var/log/curator.log --loglevel INFO --logformat default --host elasticsearch.company.org --port 9200 replicas --count 4 indices --prefix 'logstash-' --time-unit days --timestring '\%Y.\%m.\%d'" }
    end
  end

end
