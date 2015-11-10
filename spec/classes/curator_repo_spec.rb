require 'spec_helper'

describe 'curator', :type => :class do
  let(:params) {
    {
      :ensure       => '3.4.0',
      :manage_repo  => true,
      :package_name => 'python-elasticsearch-curator',
      :repo_version => '3',
    }
  }
  context 'Repo class on RedHat/CentOS' do
    let(:facts) {
      {
        :osfamily => 'RedHat',
      }
    }

    it { should create_class('curator::repo') }
    it { should contain_yumrepo('curator').with(:baseurl => 'http://packages.elastic.co/curator/3/centos/') }
  end

  context 'Repo class on Debian/Ubuntu' do
    let(:facts) {
      {
        :lsbdistid => 'Debian',
        :osfamily  => 'Debian'
      }
    }

    it { should create_class('curator::repo') }
    it { should contain_apt__source('curator').with(:location => 'http://packages.elastic.co/curator/3/debian') }
  end

  context 'set package version and package name and manage repository for yum' do
    let(:facts) {
      {
        :osfamily => 'RedHat',
      }
    }
    it { should contain_package('python-elasticsearch-curator').with(:ensure => '3.4.0') }
  end

  context 'set package version and package name and manage repository for apt' do
    let(:facts) {
      {
        :lsbdistid => 'Debian',
        :osfamily  => 'Debian',
      }
    }
    it { should contain_package('python-elasticsearch-curator').with(:ensure => '3.4.0') }
  end
end
