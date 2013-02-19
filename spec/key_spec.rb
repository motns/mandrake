require 'spec_helper'

describe Mandrake::Key do

  context "::initialize" do
    context "when called with a valid name and type" do
      context "and no options" do
        subject { described_class.new(:title, :String) }
        its(:required) { should be_false }
        its(:default) { should be_nil }
      end

      context "and :required = true" do
        subject { described_class.new(:title, :String, required: true) }
        its(:required) { should be_true }
        its(:default) { should be_nil }
      end

      context "and a :default of 123 (scalar value)" do
        subject { described_class.new(:title, :String, default: 123) }
        its(:required) { should be_false }
        its(:default) { should eq(123) }
      end

      context 'and a :description of "my favourite key"' do
        subject { described_class.new(:title, :String, description: "my favourite key") }
        its(:description) { should eq("my favourite key") }
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