require 'spec_helper'

describe Mandrake::Validator::ValueMatch do
  context "::validate" do
    subject { described_class }

    context "when called with nil, nil" do
      it { subject.validate(nil, nil).should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "peter parker", "batman"' do
      it { subject.validate("peter parker", "batman").should be_false }
      its(:last_error_code) { should eq(:no_match) }
      its(:last_error) { should eq("must be the same") }
    end

    context 'when called with "batman", "batman"' do
      it { subject.validate("batman", "batman").should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with 25, 25' do
      it { subject.validate(25, 25).should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with FalseClass, FalseClass' do
      it { subject.validate(false, false).should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
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