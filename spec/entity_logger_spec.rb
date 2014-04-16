require 'spec_helper'

describe EntityLogger do
  class EntityClass
    include EntityLogger::Mixin

    log ActiveSupport::TaggedLogging.new(Logger.new(STDOUT)), 'Prefix', :attr1 => lambda { |e| 'T' }, :attr2 => lambda { |e| 'D' }, :attr3 => lambda { |e| e.attr1 + e.attr2 }

    def attr1
      'test1'
    end

    def attr2
      'test2'
    end
  end

  describe "#log_with_tags" do
    it 'should wrap inner log call with tags' do
      obj = EntityClass.new
      obj.log_with_tags { obj.info('test') }.should be_true
    end
  end

  %w(info debug error).each do |level|
    it "should receive logger method: #{level}" do
      obj = EntityClass.new
      Logger.any_instance.should_receive(level.to_sym).with('Test')
      obj.send(level, 'Test')
    end
  end
end
