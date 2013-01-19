require 'spec_helper'

describe Mandrake::Type::Boolean do

  context "::initialize" do
    context "called with nil" do
      before do
        @attribute = described_class.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with a Boolean" do
      before do
        @attribute = described_class.new(true)
      end

      it "sets the value to given value" do
        @attribute.value.should be_true
      end
    end
  end


  context "#value" do
    before do
      @attribute = described_class.new(false)
    end

    it "returns the current value" do
      @attribute.value.should be_false
    end
  end


  context "#value=" do
    before do
      @attribute = described_class.new(nil)
    end


    context "called with a TrueClass" do
      before do
        @attribute.value = true
      end

      it "sets the value to true" do
        @attribute.value.should be_true
      end
    end


    context "called with a FalseClass" do
      before do
        @attribute.value = false
      end

      it "sets the value to false" do
        @attribute.value.should be_false
      end
    end


    context "called with a non-Boolean" do
      before do
        @attribute = described_class.new("true")
      end

      it "casts the value into Boolean" do
        @attribute.value.should be_true
      end
    end
  end
end