require 'spec_helper_acceptance'

describe 'curator jobs' do

  context 'install job' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'curator': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe command('which makemework') do
      its(:exit_status) { should eq 0 }
    end

  end

end
