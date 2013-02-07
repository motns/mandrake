require 'spec_helper'

describe Mandrake::Validator::Absence do
  context "::validate" do
    context "called with nil" do
      it "returns true" do
        described_class.send(:validate, nil).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with empty string" do
      it "returns true" do
        described_class.send(:validate, "").should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with boolean" do
      it "returns false as a fall-back" do
        described_class.send(:validate, false).should be_false
      end

      it "sets the error code to :present" do
        described_class.send(:last_error_code).should eq(:present)
      end

      it "sets the error message for :present" do
        described_class.send(:last_error).should eq("must be absent")
      end
    end


    context "called with numeric" do
      it "returns false as a fall-back" do
        described_class.send(:validate, 0).should be_false
      end

      it "sets the error code to :present" do
        described_class.send(:last_error_code).should eq(:present)
      end

      it "sets the error message for :present" do
        described_class.send(:last_error).should eq("must be absent")
      end
    end


    context "called with non-empty string" do
      it "returns false" do
        described_class.send(:validate, "peter parker").should be_false
      end

      it "sets the error code to :present" do
        described_class.send(:last_error_code).should eq(:present)
      end

      it "sets the error message for :present" do
        described_class.send(:last_error).should eq("must be absent")
      end
    end
  end
end