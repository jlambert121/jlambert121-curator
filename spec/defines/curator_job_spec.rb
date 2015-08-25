require 'spec_helper'

describe 'curator::job', :type => :define do
  let(:title) { 'myjob' }
  let(:pre_condition) { 'include curator' }

  context 'invalid command' do
    let(:params) { { :command => 'invalid' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'ensure absent' do
    let(:params) { { :command => 'alias', :alias_name => 'archive', :ensure => 'absent' } }
    it { should contain_cron('curator_myjob').with(:ensure => 'absent') }
  end

  context 'alias' do
    context 'missing alias_name' do
      let(:params) { { :command => 'alias' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'invalid remove' do
      let(:params) { { :command => 'alias', :alias_name => 'archive', :remove => 'bob' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'valid params' do
      let(:params) { { :command => 'alias', :alias_name => 'archive', :remove => true } }
      it { should contain_cron('curator_myjob').with(:command => /alias --name archive --remove/) }
    end
  end

  context 'allocation' do
    context 'missing rule' do
      let(:params) { { :command => 'allocation' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'valid params' do
      let(:params) { { :command => 'allocation', :rule => 'tag=ssd' } }
      it { should contain_cron('curator_myjob').with(:command => /allocation --rule tag=ssd/) }
    end
  end

  context 'open' do
    context 'valid params' do
      let(:params) { { :command => 'open' } }
      it { should contain_cron('curator_myjob').with(:command => /open/) }
    end
  end

  context 'close' do
    context 'valid params' do
      let(:params) { { :command => 'close' } }
      it { should contain_cron('curator_myjob').with(:command => /close/) }
    end
  end

  context 'delete' do
    context 'invalid sub_command' do
      let(:params) { { :command => 'delete', :sub_command => 'bad' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'invalid disk_space' do
      let(:params) { { :command => 'delete', :disk_space => 'bad' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'without disk_space' do
      let(:params) { { :command => 'delete' } }
      it { should contain_cron('curator_myjob').with(:command => /delete/ ) }
      it { should_not contain_cron('curator_myjob').with(:command => /--disk-space/ ) }
    end

    context 'with disk_space' do
      let(:params) { { :command => 'delete', :disk_space => '1024' } }
      it { should contain_cron('curator_myjob').with(:command => /delete --disk-space 1024 indices/ ) }
    end

    context 'with repository' do
      let(:params) { { :command => 'delete', :repository => 'old' } }
      it { should contain_cron('curator_myjob').with(:command => /delete indices --repository old/)}
    end
  end

  context 'optimize' do
    context 'invalid delay' do
      let(:params) { { :command => 'optimize', :delay => 'bob' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'invalid max_num_segments' do
      let(:params) { { :command => 'optimize', :max_num_segments => 'bob' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'invalid request_timeout' do
      let(:params) { { :command => 'optimize', :request_timeout => 'bob' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'without params' do
      let(:params) { { :command => 'optimize' } }
      it { should contain_cron('curator_myjob').with(:command => /optimize --delay 0 --max_num_segments 2 --request_timeout 218600/ ) }
    end
  end

  context 'replicas' do
    context 'bad count' do
      let(:params) { { :command => 'replicas', :count => 'bob' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'valid parameters' do
      let(:params) { { :command => 'replicas', :count => 4 } }
      it { should contain_cron('curator_myjob').with(:command => /replicas --count 4/) }
    end
  end

  context 'snapshot' do
    context 'missing repository' do
      let(:params) { { :command => 'snapshot' } }
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'valid params' do
      let(:params) { { :command => 'snapshot', :repository => 'archive' } }
      it { should contain_cron('curator_myjob').with(:command => /snapshot --repository archive/) }
    end
  end

 context 'set all other params' do
   let(:params) { {
     :command      => 'open',
     :host         => 'es.mycompany.com',
     :port         => 1000,
     :prefix       => 'example',
     :time_unit    => 'hours',
     :timestring   => '%Y%m%d%h',
     :logfile      => '/data/curator.log',
     :log_level    => 'WARN',
     :logformat    => 'logstash',
     :master_only  => true
   } }
   it { should contain_cron('curator_myjob').with(:command => "/bin/curator --logfile /data/curator.log --loglevel WARN --logformat logstash --master-only --host es.mycompany.com --port 1000 open indices --prefix 'example' --time-unit hours --timestring '%Y%m%d%h' >/dev/null") }
 end

end
