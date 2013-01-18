require 'spec_helper'

describe Mandrake::Type::String do

  context "::initialize" do
    context "called with nil" do
      before do
        @attribute = described_class.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with a String" do
      before do
        @attribute = described_class.new("bazinga!")
      end

      it "sets the value to given String" do
        @attribute.value.should eq("bazinga!")
      end
    end


    context "called with a non-String" do
      before do
        @attribute = described_class.new(42)
      end

      it "casts the value into String" do
        @attribute.value.should eq("42")
      end
    end
  end


  context "::params" do
    context "returns hash" do
      it "including :length with a default of 50" do
        described_class.params.should include(:length)
        described_class.params[:length].should eq(50)
      end

      it "including :format with a default of nil" do
        described_class.params.should include(:format)
        described_class.params[:format].should be_nil
      end
    end
  end
end