require 'spec_helper'

describe Mandrake::Type::Decimal do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
    end

    context "called with BigDecimal 7.2" do
      subject { described_class.new(BigDecimal("7.2")) }
      its (:value) { should eq(BigDecimal("7.2")) }
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
    context "when base value is BigDecimal 7.2" do
      subject { described_class.new(BigDecimal("7.2")) }

      context "called without arguments" do
        before { subject.increment }
        its(:value) { should eq(BigDecimal("8.2")) }
        its(:incremented_by) { should eq(BigDecimal("1.0")) }
      end

      context "called with BigDecimal 1.6" do
        before { subject.increment(BigDecimal("1.6")) }
        its(:value) { should eq(BigDecimal("8.8")) }
        its(:incremented_by) { should eq(BigDecimal("1.6")) }
      end

      context "called with BigDecimal -2.1" do
        before { subject.increment(BigDecimal("-2.1")) }
        its(:value) { should eq(BigDecimal("5.1")) }
        its(:incremented_by) { should eq(BigDecimal("-2.1")) }
      end

      context "called with 2" do
        before { subject.increment(2) }
        its(:value) { should eq(BigDecimal("9.2")) }
        its(:incremented_by) { should eq(BigDecimal("2.0")) }
      end

      context "called with 2.3" do
        before { subject.increment(2.3) }
        its(:value) { should eq(BigDecimal("9.5")) }
        its(:incremented_by) { should eq(BigDecimal("2.3")) }
      end

      context "called with incompatible argument" do
        it "raises an error" do
          expect {
            subject.increment("aaa")
          }.to raise_error('The increment has to be a BigDecimal, Float or Integer - String given')
        end
      end

      context "called via #inc" do
        context "with BigDecimal 1.6" do
          before { subject.inc(BigDecimal("1.6")) }
          its(:value) { should eq(BigDecimal("8.8")) }
          its(:incremented_by) { should eq(BigDecimal("1.6")) }
        end
      end
    end
  end


  context "#value" do
    context "when value is BigDecimal 3.2" do
      subject { described_class.new(BigDecimal("3.2")) }
      it "returns BigDecimal 3.2" do
        subject.value.should eq(BigDecimal("3.2"))
      end
    end
  end


  context "#value=" do
    context "when base value is BigDecimal 10.0" do
      subject { described_class.new(BigDecimal("10.0")) }

      context "called with BigDecimal 13.4" do
        before { subject.value = BigDecimal("13.4") }
        its(:value) { should eq(BigDecimal("13.4")) }
        it("resets incremented_by to 0.0") { subject.incremented_by.should eq(BigDecimal("0.0")) }
      end

      context "called with 13" do
        before { subject.value = 13 }
        its(:value) { should eq(BigDecimal("13.0")) }
        it("resets incremented_by to 0.0") { subject.incremented_by.should eq(BigDecimal("0.0")) }
      end

      context "called with 13.2" do
        before { subject.value = 13.2 }
        its(:value) { should eq(BigDecimal("13.2")) }
        it("resets incremented_by to 0.0") { subject.incremented_by.should eq(BigDecimal("0.0")) }
      end

      context "with an incompatible argument" do
        before { subject.value = "aaa" }
        its(:value) { should be_nil }
        it("resets incremented_by to 0.0") { subject.incremented_by.should eq(BigDecimal("0.0")) }
      end
    end
  end

end