require 'rspec'
require 'tagmatic'

describe TagMatic do
  let( :tagmatic ) { TagMatic.new }
  it { tagmatic.should be_an_instance_of(TagMatic) }
end
