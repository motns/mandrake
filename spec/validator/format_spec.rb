require 'spec_helper'

describe Mandrake::Validator::Format do
  context "::validate" do
    context "called with format: :email" do
      context "and valid email" do
        it "returns true" do
          described_class.send(:validate, "adam@hipsnip.com", format: :email).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end

      context "and invalid email" do
        it "returns false" do
          described_class.send(:validate, "peter@parker", format: :email).should be_false
        end

        it "sets the error code to :not_email" do
          described_class.send(:last_error_code).should eq(:not_email)
        end

        it "sets the error message for :not_email" do
          described_class.send(:last_error).should eq("has to be a valid email address")
        end
      end
    end


    context "called with format: :ip" do
      context "and valid ip address" do
        it "returns true" do
          described_class.send(:validate, "192.168.0.100", format: :ip).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end

      context "and invalid ip address" do
        it "returns false" do
          described_class.send(:validate, "11.12.13", format: :ip).should be_false
        end

        it "sets the error code to :not_ip" do
          described_class.send(:last_error_code).should eq(:not_ip)
        end

        it "sets the error message for :not_ip" do
          described_class.send(:last_error).should eq("has to be a valid ip address")
        end
      end
    end


    context "called with format: :alnum" do
      context "and valid alphanumeric string" do
        it "returns true" do
          described_class.send(:validate, "peter12parker34", format: :alnum).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end

      context "and invalid alphanumeric string" do
        it "returns false" do
          described_class.send(:validate, "peter parker", format: :alnum).should be_false
        end

        it "sets the error code to :not_alnum" do
          described_class.send(:last_error_code).should eq(:not_alnum)
        end

        it "sets the error message for :not_alnum" do
          described_class.send(:last_error).should eq("can only contain letters and numbers")
        end
      end
    end


    context "called with format: :hex" do
      context "and valid hex string" do
        it "returns true" do
          described_class.send(:validate, "1a2b3c4d5e6f", format: :hex).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end

      context "and invalid hex string" do
        it "returns false" do
          described_class.send(:validate, "7g8h9i0j", format: :hex).should be_false
        end

        it "sets the error code to :not_hex" do
          described_class.send(:last_error_code).should eq(:not_hex)
        end

        it "sets the error message for :not_hex" do
          described_class.send(:last_error).should eq("has to be a valid hexadecimal number")
        end
      end
    end


    context "called with format: Regexp" do
      context "and valid string" do
        it "returns true" do
          described_class.send(:validate, "mytext", format: /\w+/).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end

      context "and invalid string" do
        it "returns false" do
          described_class.send(:validate, "mytext", format: /\d+/).should be_false
        end

        it "sets the error code to :wrong_format" do
          described_class.send(:last_error_code).should eq(:wrong_format)
        end

        it "sets the error message for :wrong_format" do
          described_class.send(:last_error).should eq("has to be in the correct format")
        end
      end
    end


    context "called without a :format parameter" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "")
        }.to raise_error('Missing :format parameter for Format validator')
      end
    end


    context "called with a :format parameter that's neither Regexp nor Symbol" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "", format: "my format")
        }.to raise_error('The :format parameter has to be either a Symbol or a Regexp, String given')
      end
    end


    context "called with a :format Symbol which refers to a non-existent format" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "", format: :magic)
        }.to raise_error('Unknown format "magic" in Format validator')
      end
    end
  end
end