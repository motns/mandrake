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


  context "#value" do
    before do
      @attribute = described_class.new("Peter Parker")
    end

    it "returns the current value" do
      @attribute.value.should eq("Peter Parker")
    end
  end


  context "#value=" do
    before do
      @attribute = described_class.new("Peter Parker")
    end

    context "called with a String" do
      before do
        @attribute.value = "Bruce Wayne"
      end

      it "sets the value to given String" do
        @attribute.value.should eq("Bruce Wayne")
      end
    end


    context "called with a non-String" do
      before do
        @attribute = described_class.new(456)
      end

      it "casts the value into String" do
        @attribute.value.should eq("456")
      end
    end
  end
end