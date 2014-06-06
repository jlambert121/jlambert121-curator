require 'spec_helper'

describe 'curator', :type => :class do

  it { should create_class('curator') }

  it { should contain_package('python-elasticsearch-curator').with(:ensure => 'latest') }

  context 'set package name and version' do
    let(:params) { { :ensure => '1.2.3', :package_name => 'elasticsearch-curator' } }
    it { should contain_package('elasticsearch-curator').with(:ensure => '1.2.3') }
  end

end

