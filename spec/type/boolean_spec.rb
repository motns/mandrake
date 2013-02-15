require 'spec_helper'

describe Mandrake::Type::Boolean do

  context "::initialize" do
    context "when called with nil" do
      subject { described_class.new(nil) }
      its(:value) { should be_nil }
    end

    context "when called with a TrueClass" do
      subject { described_class.new(true) }
      its(:value) { should be_true }
    end
  end


  context "#value" do
    context "when the value is false" do
      subject { described_class.new(false) }
      it "returns false" do
        subject.value.should be_false
      end
    end
  end


  context "#value=" do
    subject { described_class.new(nil) }

    context "when called with a TrueClass" do
      before { subject.value = true }
      its(:value) { should be_true}
    end

    context "called with a FalseClass" do
      before { subject.value = false }
      its(:value) { should be_false}
    end

    context 'called with a truthy non-Boolean - "false"' do
      before { subject.value = "false" }
      its(:value) { should be_true }
    end
  end
end