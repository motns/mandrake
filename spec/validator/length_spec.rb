require 'spec_helper'

describe Mandrake::Validator::Length do
  context "::validate" do
    subject { described_class }

    context "with parameter {:length => 4..10}" do
      context "when called with nil" do
        it { subject.validate(nil, length: 4..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with 123" do
        it { subject.validate(123, length: 4..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with FalseClass" do
        it { subject.validate(false, length: 4..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter"' do
        it { subject.validate("peter", length: 4..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "jon" (too short)' do
        it { subject.validate("jon", length: 4..10).should be_false }
        its(:last_error_code) { should eq(:short) }
        its(:last_error) { should eq("has to be longer than 4 characters") }
      end

      context 'when called with "this is way too long"' do
        it { subject.validate("this is way too long", length: 4..10).should be_false }
        its(:last_error_code) { should eq(:long) }
        its(:last_error) { should eq("has to be 10 characters or less") }
      end
    end


    context "called without a :length parameter" do
      it do
        expect {
          subject.validate("")
        }.to raise_error('Missing :legth parameter for Length validator')
      end
    end


    context "called with a non-Range :length parameter" do
      it do
        expect {
          subject.validate("", length: 12)
        }.to raise_error('The :length parameter has to be provided as a Range, Fixnum given')
      end
    end
  end
end