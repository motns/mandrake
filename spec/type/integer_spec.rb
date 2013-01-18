require 'spec_helper'

describe Mandrake::Type::Integer do

  context "::initialize" do
    context "called with nil" do
      before do
        @attribute = described_class.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with an Integer" do
      before do
        @attribute = described_class.new(15)
      end

      it "sets the value to given Integer" do
        @attribute.value.should eq(15)
      end
    end


    context "called with a non-Integer" do
      before do
        @attribute = described_class.new("123")
      end

      it "casts the value into Integer" do
        @attribute.value.should eq(123)
      end
    end
  end


  context "::params" do
    context "returns hash" do
      it "including :min with a default of nil" do
        described_class.params.should include(:min)
        described_class.params[:min].should be_nil
      end

      it "including :max with a default of nil" do
        described_class.params.should include(:max)
        described_class.params[:max].should be_nil
      end
    end
  end
end