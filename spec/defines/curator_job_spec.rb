require 'spec_helper'

describe 'curator::job', :type => :define do
  let(:title) { 'myjob' }

  # delete_older is set frequently to prevent "no older error"
  context 'no params' do
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'bad curation_style' do
    let(:params) { { :curation_style => 'bad', :delete_older => 10 } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  [ 'curation_style', 'time_unit', 'port', 'timeout', 'close_older', 'bloom_older', 'optimize_older', '$max_num_segments' ].each do |field|
    context "bad #{field}" do
      let(:prams) { { field.to_sym => 'bad', :delete_older => 10 } }
      it { expect { should raise_error(Puppet::Error) } }
    end
  end

  context 'bad delete_older' do
    let(:params) { { :delete_older => 'bad' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'bad disk_space' do
    let(:params) { { :curation_style => 'space', :disk_space => 'bad' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'default params' do
    # setting delete_older to prevent error
    let(:params) { { :delete_older => 10 } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 -t 30 -p 'logstash-' -s '.' -C time -T days -l /var/log/curator.log -d 10") }
  end

  context 'curation_style = space' do
    let(:params) { { :curation_style => 'space', :disk_space => 1024 } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 -t 30 -p 'logstash-' -s '.' -C space -T days -l /var/log/curator.log -g 1024" ) }
  end

  context 'curation_style = space and delete_older' do
    let(:params) { { :curation_style => 'space', :disk_space => 1024, :delete_older => 10 } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'optimize_older, timeout < 3600' do
    let(:params) { { :optimize_older => 2, :timeout => 3599}}
    it { expect { should raise_error(Puppet::Warning) } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 -t 3599 -p 'logstash-' -s '.' -C time -T days -l /var/log/curator.log -o 2 --max_num_segments 2") }
  end

  context 'all orders' do
    let(:params) { { :delete_older => 90, :close_older => 30, :bloom_older => 2, :optimize_older => 2 } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host localhost --port 9200 -t 30 -p 'logstash-' -s '.' -C time -T days -l /var/log/curator.log -d 90 -c 30 -b 2 -o 2 --max_num_segments 2") }
  end

  context 'set all other params' do
    let(:params) { {
      :host         => 'es.mycompany.com',
      :port         => 1000,
      :timeout      => 200,
      :prefix       => 'example',
      :separator    => '-',
      :time_unit    => 'hours',
      :logfile      => '/data/curator.log',
      :delete_older => 10
    } }
    it { should contain_cron('curator_myjob').with(:command => "/usr/bin/curator --host es.mycompany.com --port 1000 -t 200 -p 'example' -s '-' -C time -T hours -l /data/curator.log -d 10") }
  end

end
