require 'spec_helper'

describe Mandrake::Validator::ValueMatch do
  context "::validate" do
    context "called with two nil values" do
      it "returns true" do
        described_class.send(:validate, nil, nil).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with two different strings" do
      it "returns false" do
        described_class.send(:validate, "peter parker", "batman").should be_false
      end

      it "sets the error code to :no_match" do
        described_class.send(:last_error_code).should eq(:no_match)
      end

      it "sets the error message for :no_match" do
        described_class.send(:last_error).should eq("must be the same")
      end
    end


    context "called with the wrong number of arguments" do
      it do
        expect {
          described_class.send(:validate, "peter parker")
        }.to raise_error("This validator takes 2 value(s) for validation, 1 given")
      end
    end
  end
end