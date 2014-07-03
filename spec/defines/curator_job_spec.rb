require 'spec_helper'

describe 'curator::job', :type => :define do
  let(:title) { 'myjob' }

  # delete_older is set frequently to prevent "no older error"
  context 'no command' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'multiple commands' do
    let(:params) { { :delete_older => 10, :bloom_older => 10 } }
    it { expect { should raise_error(Puppet::Error) } }
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
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator delete --older-than 10 -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log") }
    end

    context 'space' do
      let(:params) { { :disk_space => 1024 } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator delete --disk-space 1024 -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log" ) }
    end
  end

  context 'bloom' do
    let(:params) { { :bloom_older => 10 } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator bloom --older-than 10 -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log") }
  end

  context 'optimize' do
    context 'optimze_older' do
      let(:params) { { :optimize_older => 10 } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator optimize --older-than 10 --max_num_segments 2 -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log") }
    end

  end

  context 'allocation' do
    context 'missing tag' do
      let(:params) { { :allocation_older => 10 } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'correct params' do
      let(:params) { { :allocation_older => 10, :rule => 'tag=something' } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator allocation --older-than 10 --rule tag=something -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log") }
    end
  end

  context 'snapshot' do
    context 'without repository' do
      let(:params) { { :snapshot_older => 10 } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'correct params' do
      let(:params) { { :snapshot_older => 10, :repository => 'test' } }
        it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator snapshot --older-than 10 --repository test -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log") }
    end
  end

  context 'alias' do
    context 'no alias' do
      let(:params) { { :alias_older => 7 } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'correct params' do
      let(:params) { { :alias_older => 7, :alias_name => 'last_week' } }
      it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator alias --older-than 7 --alias last_week -T days --host localhost --port 9200 -p 'logstash-' -s '.' -l /var/log/curator.log") }
    end
  end

  context 'set all other params' do
    let(:params) { {
      :host         => 'es.mycompany.com',
      :port         => 1000,
      :prefix       => 'example',
      :separator    => '-',
      :time_unit    => 'hours',
      :logfile      => '/data/curator.log',
      :delete_older => 10
    } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator delete --older-than 10 -T hours --host es.mycompany.com --port 1000 -p 'example' -s '-' -l /data/curator.log") }
  end

end
