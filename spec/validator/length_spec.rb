require 'spec_helper'

describe Mandrake::Validator::Length do
  context "::validate" do
    context "called with nil" do
      it "returns true" do
        described_class.send(:validate, nil, length: 0..10).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with integer" do
      it "returns true as fallback" do
        described_class.send(:validate, 123, length: 0..10).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with string that's too short" do
      it "returns false" do
        described_class.send(:validate, "pete", length: 5..10).should be_false
      end

      it "sets the error code to :short" do
        described_class.send(:last_error_code).should eq(:short)
      end

      it "sets the error message for :short" do
        described_class.send(:last_error).should eq("has to be longer than 5 characters")
      end
    end


    context "called with string that's too long" do
      it "returns false" do
        described_class.send(:validate, "this is way too long", length: 5..10).should be_false
      end

      it "sets the error code to :long" do
        described_class.send(:last_error_code).should eq(:long)
      end

      it "sets the error message for :long" do
        described_class.send(:last_error).should eq("has to be shorter than 10 characters")
      end
    end


    context "called with string that's the right length" do
      it "returns false" do
        described_class.send(:validate, "just right", length: 5..10).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called without a :length parameter" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "")
        }.to raise_error('Missing :legth parameter for Length validator')
      end
    end


    context "called with a non-Range :length parameter" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "", length: 12)
        }.to raise_error('The :length parameter has to be provided as a Range, Fixnum given')
      end
    end
  end
end