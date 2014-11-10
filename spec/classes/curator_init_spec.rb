require 'spec_helper'

describe 'curator', :type => :class do

  it { should create_class('curator') }

  it { should contain_package('python-elasticsearch-curator').with(:ensure => 'latest') }

  context 'set package version and use default provider' do
    let(:params) { { :ensure => '1.2.3' } }
    it { should contain_package('python-elasticsearch-curator').with(:ensure => '1.2.3') }
  end

  context 'set package version and package name and use default provider' do
    let(:params) {
      {
        :ensure => '1.2.3',
        :package_name => 'elasticsearch-curator',
      }
    }
    it { should contain_package('elasticsearch-curator').with(:ensure => '1.2.3') }
  end

  context 'pip provider' do
    context 'with manage_pip' do
      let(:params) { { :provider => 'pip', :manage_pip => true } }
      it { should contain_package('python-pip').with(:ensure => 'installed', :before => 'Package[elasticsearch-curator]') }
      it { should contain_package('elasticsearch-curator').with(:ensure => 'latest') }
    end

    context 'no manage_pip' do
      let(:params) { { :provider => 'pip' } }
      it { should_not contain_package('python-pip') }
      it { should contain_package('elasticsearch-curator').with(:ensure => 'latest') }
    end
  end

  context 'require version >= 1.1.0' do
    let(:prams) { { :ensure => '1.0.0' } }
    it { expect { should raise_error(Puppet::Error) } }
  end

end

