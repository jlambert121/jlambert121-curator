require 'spec_helper'

describe 'curator::job', :type => :define do
  let(:title) { 'myjob' }

  # delete_older is set frequently to prevent "no older error"
  context 'no command' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'multiple commands' do
    let(:params) { { :delete_older => 10, :bloom_older => 10 } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log delete --older-than 10 --time-unit days --prefix 'logstash-' && /usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log bloom --older-than 10 --time-unit days --prefix 'logstash-'") }
  end

  context 'bad curation_style' do
    let(:params) { { :curation_style => 'bad', :delete_older => 10 } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  [ 'curation_style', 'time_unit', 'port', 'max_num_segments' ].each do |field|
    context "bad #{field}" do
      let(:prams) { { field.to_sym => 'bad', :optimize_older => 10 } }
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  [ 'disk_space', 'delete_older', 'close_older', 'bloom_older', 'optimize_older', 'allocation_older', 'snapshot_older', 'alias_older' ].each do |field|
    context "bad #{field}" do
      let(:prams) { { field.to_sym => 'bad' } }
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  context 'delete' do
    context 'older' do
      # setting delete_older to prevent error
      let(:params) { { :delete_older => 10 } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log delete --older-than 10 --time-unit days --prefix 'logstash-'") }
    end

    context 'space' do
      let(:params) { { :disk_space => 1024 } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log delete --disk-space 1024 --time-unit days --prefix 'logstash-'" ) }
    end
  end

  context 'bloom' do
    let(:params) { { :bloom_older => 10 } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log bloom --older-than 10 --time-unit days --prefix 'logstash-'") }
  end

  context 'optimize' do
    context 'optimze_older' do
      let(:params) { { :optimize_older => 10 } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log optimize --older-than 10 --max_num_segments 2 --time-unit days --prefix 'logstash-'") }
    end

  end

  context 'allocation' do
    context 'missing tag' do
      let(:params) { { :allocation_older => 10 } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'correct params' do
      let(:params) { { :allocation_older => 10, :rule => 'tag=something' } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log allocation --older-than 10 --rule tag=something --time-unit days --prefix 'logstash-'") }
    end
  end

  context 'snapshot' do
    context 'without repository' do
      let(:params) { { :snapshot_older => 10 } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'correct params' do
      let(:params) { { :snapshot_older => 10, :repository => 'test' } }
        it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log snapshot --older-than 10 --repository test --time-unit days --prefix 'logstash-'") }
    end
  end

  context 'alias' do
    context 'no alias' do
      let(:params) { { :alias_older => 7 } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'correct params' do
      let(:params) { { :alias_older => 7, :alias_name => 'last_week' } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 --logfile /var/log/curator.log alias --older-than 7 --alias last_week --time-unit days --prefix 'logstash-'") }
    end
  end

  context 'set all other params' do
    let(:params) { {
      :host         => 'es.mycompany.com',
      :port         => 1000,
      :prefix       => 'example',
      :time_unit    => 'hours',
      :logfile      => '/data/curator.log',
      :master_only  => true,
      :delete_older => 10
    } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --master-only --host es.mycompany.com --port 1000 --logfile /data/curator.log delete --older-than 10 --time-unit hours --prefix 'example'") }
  end

end
