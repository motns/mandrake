require 'spec_helper'

describe Mandrake::Validator::Format do
  context "::validate" do
    subject { described_class }

    context "with parameter {:format => :email}" do
      context "when called with nil" do
        it { subject.validate(nil, format: :email).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "adam@hipsnip.com"' do
        it { subject.validate("adam@hipsnip.com", format: :email).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "john1000+test@gmail.com"' do
        it { subject.validate("john1000+test@gmail.com", format: :email).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "john@uni.edu.ac.uk"' do
        it { subject.validate("john@uni.edu.ac.uk", format: :email).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter@parker"' do
        it { subject.validate("peter@parker", format: :email).should be_false }
        its(:last_error_code) { should eq(:not_email) }
        its(:last_error) { should eq("has to be a valid email address") }
      end
    end


    context "with parameter {:format => :ip}" do
      context "when called with nil" do
        it { subject.validate(nil, format: :ip).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "192.168.0.100"' do
        it { subject.validate("192.168.0.100", format: :ip).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "11.12.13"' do
        it { subject.validate("11.12.13", format: :ip).should be_false }
        its(:last_error_code) { should eq(:not_ip) }
        its(:last_error) { should eq("has to be a valid ip address") }
      end
    end


    context "with parameter {:format => :alnum}" do
      context "when called with nil" do
        it { subject.validate(nil, format: :alnum).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter12parker34"' do
        it { subject.validate("peter12parker34", format: :alnum).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter parker"' do
        it { subject.validate("peter parker", format: :alnum).should be_false }
        its(:last_error_code) { should eq(:not_alnum) }
        its(:last_error) { should eq("can only contain letters and numbers") }
      end
    end


    context "with parameter {:format => :hex}" do
      context "when called with nil" do
        it { subject.validate(nil, format: :hex).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "1a2b3c4d5e6f"' do
        it { subject.validate("1a2b3c4d5e6f", format: :hex).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "7g8h9i0j"' do
        it { subject.validate("7g8h9i0j", format: :hex).should be_false }
        its(:last_error_code) { should eq(:not_hex) }
        its(:last_error) { should eq("has to be a valid hexadecimal number") }
      end
    end


    context 'with parameter {:format => /^\w+$/}' do
      context "when called with nil" do
        it { subject.validate(nil, format: /^\w+$/).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "mytext"' do
        it { subject.validate("mytext", format: /^\w+$/).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "12 34"' do
        it { subject.validate("12 34", format: /^\w+$/).should be_false }
        its(:last_error_code) { should eq(:wrong_format) }
        its(:last_error) { should eq("has to be in the correct format") }
      end
    end


    context "called without a :format parameter" do
      it do
        expect {
          subject.validate("")
        }.to raise_error('Missing :format parameter for Format validator')
      end
    end


    context "called with a :format parameter that's neither Regexp nor Symbol" do
      it do
        expect {
          subject.validate("", format: 123)
        }.to raise_error('The :format parameter has to be either a Symbol or a Regexp, Fixnum given')
      end
    end


    context "called with a :format Symbol which refers to a non-existent format" do
      it do
        expect {
          subject.validate("", format: :magic)
        }.to raise_error('Unknown format "magic" in Format validator')
      end
    end
  end
end