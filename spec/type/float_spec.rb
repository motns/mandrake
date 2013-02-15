require 'spec_helper'

describe Mandrake::Type::Float do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
    end

    context "called with 7.2" do
      subject { described_class.new(7.2) }
      its (:value) { should eq(7.2) }
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
    context "when base value is 7.2" do
      subject { described_class.new(7.2) }

      context "called without arguments" do
        before { subject.increment }
        its(:value) { should eq(8.2) }
        its(:incremented_by) { should eq(1.0) }
      end

      context "called with 1.6" do
        before { subject.increment(1.6) }
        its(:value) { should eq(8.8) }
        its(:incremented_by) { should eq(1.6) }
      end

      context "called with -2.1" do
        before { subject.increment(-2.1) }
        its(:value) { should eq(5.1) }
        its(:incremented_by) { should eq(-2.1) }
      end

      context "called with 2" do
        it "raises an error" do
          expect {
            subject.increment(2)
          }.to raise_error('The increment has to be a Float, Fixnum given')
        end
      end

      context "called via #inc" do
        context "with 1.6" do
          before { subject.inc(1.6) }
          its(:value) { should eq(8.8) }
          its(:incremented_by) { should eq(1.6) }
        end
      end
    end
  end


  context "#value" do
    context "when value is 3.2" do
      subject { described_class.new(3.2) }
      it "returns 3.2" do
        subject.value.should eq(3.2)
      end
    end
  end


  context "#value=" do
    context "when base value is 10.0" do
      subject { described_class.new(10.0) }

      context "called with 13.4" do
        before { subject.value = 13.4 }
        its(:value) { should eq(13.4) }
        it("resets incremented_by to 0.0") { subject.incremented_by.should eq(0.0) }
      end

      context 'called with "12.3"' do
        before { subject.value = "12.3" }
        its(:value) { should eq(12.3) }
        it("resets incremented_by to 0.0") { subject.incremented_by.should eq(0.0) }
      end
    end
  end

end