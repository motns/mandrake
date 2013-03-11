require 'spec_helper'

describe Mandrake::Type::Decimal do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
      its(:incremented_by) { should eq(BigDecimal("0.0")) }
      its(:changed_by) { should eq(:setter) }
    end

    context "called with BigDecimal 7.2" do
      subject { described_class.new(BigDecimal("7.2")) }
      its (:value) { should eq(BigDecimal("7.2")) }
      its(:incremented_by) { should eq(BigDecimal("0.0")) }
      its(:changed_by) { should eq(:setter) }
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
      context "called without arguments" do
        subject do
          type = described_class.new(BigDecimal("7.2"))
          type.increment
          type
        end
        its(:value) { should eq(BigDecimal("8.2")) }
        its(:incremented_by) { should eq(BigDecimal("1.0")) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with BigDecimal 1.6" do
        subject do
          type = described_class.new(BigDecimal("7.2"))
          type.increment(BigDecimal("1.6"))
          type
        end
        its(:value) { should eq(BigDecimal("8.8")) }
        its(:incremented_by) { should eq(BigDecimal("1.6")) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with BigDecimal -2.1" do
        subject do
          type = described_class.new(BigDecimal("7.2"))
          type.increment(BigDecimal("-2.1"))
          type
        end
        its(:value) { should eq(BigDecimal("5.1")) }
        its(:incremented_by) { should eq(BigDecimal("-2.1")) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with 2" do
        subject do
          type = described_class.new(BigDecimal("7.2"))
          type.increment(2)
          type
        end
        its(:value) { should eq(BigDecimal("9.2")) }
        its(:incremented_by) { should eq(BigDecimal("2.0")) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with 2.3" do
        subject do
          type = described_class.new(BigDecimal("7.2"))
          type.increment(2.3)
          type
        end
        its(:value) { should eq(BigDecimal("9.5")) }
        its(:incremented_by) { should eq(BigDecimal("2.3")) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with incompatible argument" do
        subject { described_class.new(BigDecimal("7.2")) }
        it do
          expect {
            subject.increment("aaa")
          }.to raise_error('The increment has to be a BigDecimal, Float or Integer - String given')
        end
      end

      context "called via #inc" do
        context "with BigDecimal 1.6" do
          subject do
            type = described_class.new(BigDecimal("7.2"))
            type.inc(BigDecimal("1.6"))
            type
          end
          its(:value) { should eq(BigDecimal("8.8")) }
          its(:incremented_by) { should eq(BigDecimal("1.6")) }
        end
      end
    end
  end


  context "#increment and #value= combined" do
    context "when base value is BigDecimal 7.2" do
      context "first setting to BigDecimal 8.2 then incrementing by 1.1" do
        subject do
          type = described_class.new(BigDecimal("7.2"))
          type.value = BigDecimal("8.2")
          type.increment(BigDecimal("1.1"))
          type
        end

        its(:value) { should eq(BigDecimal("9.3")) }
        its(:incremented_by) { should eq(BigDecimal("1.1")) }
        its(:changed_by) { should eq(:setter) }
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
      context "called with BigDecimal 13.4" do
        subject do
          type = described_class.new(BigDecimal("10.0"))
          type.value = BigDecimal("13.4")
          type
        end
        its(:value) { should eq(BigDecimal("13.4")) }
        its(:incremented_by) { should eq(BigDecimal("0.0")) }
        its(:changed_by) { should eq(:setter) }
      end

      context "called with 13" do
        subject do
          type = described_class.new(BigDecimal("10.0"))
          type.value = 13
          type
        end
        its(:value) { should eq(BigDecimal("13.0")) }
        its(:incremented_by) { should eq(BigDecimal("0.0")) }
        its(:changed_by) { should eq(:setter) }
      end

      context "called with 13.2" do
        subject do
          type = described_class.new(BigDecimal("10.0"))
          type.value = 13.2
          type
        end
        its(:value) { should eq(BigDecimal("13.2")) }
        its(:incremented_by) { should eq(BigDecimal("0.0")) }
        its(:changed_by) { should eq(:setter) }
      end

      context "with an incompatible argument" do
        subject do
          type = described_class.new(BigDecimal("10.0"))
          type.value = "aaa"
          type
        end
        its(:value) { should be_nil }
        its(:incremented_by) { should eq(BigDecimal("0.0")) }
        its(:changed_by) { should eq(:setter) }
      end
    end
  end

end