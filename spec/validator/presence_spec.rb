require 'spec_helper'

describe Mandrake::Validator::Presence do
  context "::error_codes" do
    it("returns a hash") { described_class.error_codes }
    it { described_class.error_codes.should include(:missing) }
    it { described_class.error_codes.should include(:empty) }
  end


  context "::validate" do
    context "called with nil" do
      it "returns false" do
        described_class.send(:validate, nil).should be_false
      end

      it "sets the error code to :missing" do
        described_class.send(:last_error_code).should eq(:missing)
      end

      it "sets the error message for :missing" do
        described_class.send(:last_error).should eq("must be provided")
      end
    end


    context "called with empty string" do
      it "returns false" do
        described_class.send(:validate, "").should be_false
      end

      it "sets the error code to :empty" do
        described_class.send(:last_error_code).should eq(:empty)
      end

      it "sets the error message for :empty" do
        described_class.send(:last_error).should eq("cannot be empty")
      end
    end


    context "called with boolean" do
      it "returns true as a fall-back" do
        described_class.send(:validate, false).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with numeric" do
      it "returns true as a fall-back" do
        described_class.send(:validate, 0).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with non-empty string" do
      it "returns true" do
        described_class.send(:validate, "peter parker").should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end
  end
end