require 'spec_helper'

describe Mandrake::Validator::Exclusion do
  context "::validate" do
    context "called with nil" do
      it "returns true" do
        described_class.send(:validate, nil, in: 0..10).should be_true
      end

      it "sets the error code to nil" do
        described_class.send(:last_error_code).should be_nil
      end

      it "sets the error message to nil" do
        described_class.send(:last_error).should be_nil
      end
    end


    context "called with Range as the :in parameter" do
      context "called with valid integer" do
        it "returns true" do
          described_class.send(:validate, 15, in: 0..10).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end


      context "called with a invalid integer" do
        it "returns false" do
          described_class.send(:validate, 5, in: 0..10).should be_false
        end

        it "sets the error code to :in_range" do
          described_class.send(:last_error_code).should eq(:in_range)
        end

        it "sets the error message for :in_range" do
          described_class.send(:last_error).should eq("must not be between 0 and 10")
        end
      end
    end


    context "called with Array as the :in parameter" do
      context "called with valid string" do
        it "returns true" do
          described_class.send(:validate, 'four', in: %w(one two three)).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end


      context "called with an invalid string" do
        it "returns false" do
          described_class.send(:validate, 'two', in: %w(one two three)).should be_false
        end

        it "sets the error code to :in_set" do
          described_class.send(:last_error_code).should eq(:in_set)
        end

        it "sets the error message for :in_set" do
          described_class.send(:last_error).should eq("must not be any of: one, two, three")
        end
      end
    end


    context "called with Date as the :in parameter" do
      context "called with valid date" do
        it "returns true" do
          described_class.send(:validate, 2.weeks.ago.to_date, in: 1.week.ago.to_date..Date.today).should be_true
        end

        it "sets the error code to nil" do
          described_class.send(:last_error_code).should be_nil
        end

        it "sets the error message to nil" do
          described_class.send(:last_error).should be_nil
        end
      end


      context "called with an invalid date" do
        it "returns false" do
          described_class.send(:validate, 2.days.ago.to_date, in: 1.week.ago.to_date..Date.today).should be_false
        end

        it "sets the error code to :in_range" do
          described_class.send(:last_error_code).should eq(:in_range)
        end

        it "sets the error message for :in_range" do
          described_class.send(:last_error).should eq("must not be between #{1.week.ago.to_date} and #{Date.today}")
        end
      end
    end


    context "called without the :in parameter" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "")
        }.to raise_error('Missing :in parameter for Exclusion validator')
      end
    end


    context "called with a non-Enumerable :in parameter" do
      it "throws an exception" do
        expect {
          described_class.send(:validate, "", in: 12)
        }.to raise_error('The :in parameter must be provided as an Enumerable, Fixnum given')
      end
    end
  end
end