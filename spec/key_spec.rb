require 'spec_helper'

describe Mandrake::Key do

  context "::initialize" do
    context "when called with a type parameter that can't be converted to a Symbol" do
      it "throws an exception" do
        expect {
          described_class.new(:title, String)
        }.to raise_error('Key type should be provided as a Symbol')
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