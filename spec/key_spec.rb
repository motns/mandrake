require 'spec_helper'

describe Mandrake::Key do

  context "::initialize" do
    context "when called with a valid name and type" do
      context "and no options" do
        before(:all) do
          @key_object = described_class.new(:title, :String)
        end

        it "sets :required to false" do
          @key_object.required.should be_false
        end

        it "sets :default to nil" do
          @key_object.default.should be_nil
        end
      end


      context "and :required = true" do
        before(:all) do
          @key_object = described_class.new(:title, :String, required: true)
        end

        it "sets :required to true" do
          @key_object.required.should be_true
        end

        it "sets :default to nil" do
          @key_object.default.should be_nil
        end
      end


      context "and :default as a scalar" do
        before(:all) do
          @key_object = described_class.new(:title, :String, default: 123)
        end

        it "sets :required to false" do
          @key_object.required.should be_false
        end

        it "sets :default to scalar value" do
          @key_object.default.should eq(123)
        end
      end
    end


    context "when called with a type parameter that can't be converted to a Symbol" do
      it "throws an exception" do
        expect {
          described_class.new(:title, String)
        }.to raise_error('Key type should be provided as a Symbol, Class given')
      end
    end


    context "when called with an unknown type" do
      it "throws an exception" do
        expect {
          described_class.new(:vehicle, :Batmobil)
        }.to raise_error('Unknown Mandrake type: Batmobil')
      end
    end
  end
end