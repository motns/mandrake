require 'spec_helper'

describe Mandrake::Type::Integer do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
    end

    context "called with 15" do
      subject { described_class.new(15) }
      its (:value) { should eq(15) }
    end
  end


  context "::params" do
    it { described_class.params.should be_a(::Hash) }
    it { described_class.params.should include(:in) }
    it "should default :in to nil" do
      described_class.params[:in].should be_nil
    end
  end


  context "#increment" do
    context "when base value is 10" do
      subject { described_class.new(10) }

      context "called without arguments" do
        before { subject.increment }
        its(:value) { should eq(11) }
        its(:incremented_by) { should eq(1) }
      end

      context "called with 5" do
        before { subject.increment(5) }
        its(:value) { should eq(15) }
        its(:incremented_by) { should eq(5) }
      end

      context "called with -4" do
        before { subject.increment(-4) }
        its(:value) { should eq(6) }
        its(:incremented_by) { should eq(-4) }
      end

      context "called with 2.3" do
        it "raises an error" do
          expect {
            subject.increment(2.3)
          }.to raise_error('The increment has to be an Integer, Float given')
        end
      end

      context "called via #inc" do
        context "with 2" do
          before { subject.inc(2) }
          its(:value) { should eq(12) }
          its(:incremented_by) { should eq(2) }
        end
      end
    end
  end


  context "#value" do
    context "when value is 10" do
      subject { described_class.new(10) }
      it "returns 10" do
        subject.value.should eq(10)
      end
    end
  end


  context "#value=" do
    context "when base value is 10" do
      subject { described_class.new(10) }

      context "called with 14" do
        before { subject.value = 14 }
        its(:value) { should eq(14) }
        it("resets incremented_by to 0") { subject.incremented_by.should eq(0) }
      end

      context 'called with "123"' do
        before { subject.value = "123" }
        its(:value) { should eq(123) }
        it("resets incremented_by to 0") { subject.incremented_by.should eq(0) }
      end

      context "called with value that can't be casted to Integer" do
        before { subject.value = [ 123 ] }
        its(:value) { should be_nil }
        it("resets incremented_by to 0") { subject.incremented_by.should eq(0) }
      end
    end
  end
end