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

end

