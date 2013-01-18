require 'spec_helper'

describe Mandrake::Type::String do

  describe "::initialize" do
    context "called with nil" do
      before do
        @attribute = Mandrake::Type::String.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with a String" do
      before do
        @attribute = Mandrake::Type::String.new("bazinga!")
      end

      it "sets the value to given String" do
        @attribute.value.should eq("bazinga!")
      end
    end


    context "called with a non-String" do
      before do
        @attribute = Mandrake::Type::String.new(42)
      end

      it "casts the value to String" do
        @attribute.value.should eq("42")
      end
    end
  end


  describe "::params" do
    context "returns hash" do
      it "including :length with a default of 50" do
        Mandrake::Type::String.params.should include(:length)
        Mandrake::Type::String.params[:length].should eq(50)
      end

      it "including :format with a default of nil" do
        Mandrake::Type::String.params.should include(:format)
        Mandrake::Type::String.params[:format].should be_nil
      end
    end
  end
end