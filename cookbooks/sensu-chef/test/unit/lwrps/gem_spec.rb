require_relative "../spec_helper"

describe 'sensu-test::gem_lwrp' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(:step_into => ['sensu_gem']).converge(described_recipe)
  end

  it 'defaults to action :install' do
    expect(chef_run).to install_gem_package('sensu-plugins-sensu')
  end

  context 'action :install' do
    it 'installs the specified gem package' do
      expect(chef_run).to install_gem_package('sensu-plugins-slack')
    end

    context 'version specified' do
      it 'installs the specified version of the gem package' do
        expect(chef_run).to install_gem_package('sensu-plugins-chef').with(:version => '0.0.5')
      end
    end
  end

  context 'action :remove' do
    it 'removes the specified gem package' do
      expect(chef_run).to remove_gem_package('sensu-plugins-hipchat')
    end
  end

end
