require 'spec_helper'
describe 'geonode' do

  context 'with defaults for all parameters' do
    it { should contain_class('geonode') }
  end
end
