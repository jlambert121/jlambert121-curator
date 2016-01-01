require 'spec_helper'

describe 'curator', :type => :class do

  it { should create_class('curator') }

  it { should contain_package('elasticsearch-curator').with(:ensure => 'latest') }

  context 'set package version and use default provider' do
    let(:params) { { :ensure => '3.0.0' } }
    it { should contain_package('elasticsearch-curator').with(:ensure => '3.0.0') }
  end

  context 'set package version and package name and use default provider' do
    let(:params) {
      {
        :ensure       => '3.0.0',
        :package_name => 'python-elasticsearch-curator',
      }
    }
    it { should contain_package('python-elasticsearch-curator').with(:ensure => '3.0.0') }
  end

  context 'require version >= 1.1.0' do
    let(:prams) { { :ensure => '1.0.0' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

  context 'empty jobs' do
    let(:params) { { :jobs => {} } }
    it { should_not contain_curator__job() }
  end

  context 'add a job' do
    let(:params) {
      {
        :jobs => {
          'delete_job' => {
            'command'     => 'close',
            'cron_hour'   => 6,
            'http_auth'   => true,
            'master_only' => true,
            'older_than'  => 7,
            'password'    => 'password',
            'use_ssl'     =>  true,
            'user'        => 'user',
          }
        }
      }
    }
    it { should contain_curator__job('delete_job').with({
      'command' => 'close',
      'cron_hour'   => 6,
      'http_auth'   => true,
      'master_only' => true,
      'older_than'  => 7,
      'password'    => 'password',
      'use_ssl'     => true,
      'user'        => 'user',
    }) }
  end
end
