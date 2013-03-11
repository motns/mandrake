require 'spec_helper'

describe Mandrake::Type::Integer do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
      its(:incremented_by) { should eq(0) }
      its(:changed_by) { should eq(:setter) }
    end

    context "called with 15" do
      subject { described_class.new(15) }
      its (:value) { should eq(15) }
      its(:incremented_by) { should eq(0) }
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
    context "when base value is 10" do
      context "called without arguments" do
        subject do
          type = described_class.new(10)
          type.increment
          type
        end

        its(:value) { should eq(11) }
        its(:incremented_by) { should eq(1) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with 5" do
        subject do
          type = described_class.new(10)
          type.increment(5)
          type
        end

        its(:value) { should eq(15) }
        its(:incremented_by) { should eq(5) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with -4" do
        subject do
          type = described_class.new(10)
          type.increment(-4)
          type
        end

        its(:value) { should eq(6) }
        its(:incremented_by) { should eq(-4) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with 2.3" do
        subject { described_class.new(10) }

        it do
          expect {
            subject.increment(2.3)
          }.to raise_error('The increment has to be an Integer, Float given')
        end
      end

      context "called via #inc" do
        context "with 2" do
          subject do
            type = described_class.new(10)
            type.increment(2)
            type
          end

          its(:value) { should eq(12) }
          its(:incremented_by) { should eq(2) }
          its(:changed_by) { should eq(:modifier) }
        end
      end
    end
  end


  context "#increment and #value= combined" do
    context "when base value is 7" do
      context "first setting to 8 then incrementing by 1" do
        subject do
          type = described_class.new(7)
          type.value = 8
          type.increment(1)
          type
        end

        its(:value) { should eq(9) }
        its(:incremented_by) { should eq(1) }
        its(:changed_by) { should eq(:setter) }
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
      context "called with 14" do
        subject do
          type = described_class.new(10)
          type.value = 14
          type
        end

        its(:value) { should eq(14) }
        its(:incremented_by) { should eq(0) }
        its(:changed_by) { should eq(:setter) }
      end

      context 'called with "123"' do
        subject do
          type = described_class.new(10)
          type.value = "123"
          type
        end

        its(:value) { should eq(123) }
        its(:incremented_by) { should eq(0) }
        its(:changed_by) { should eq(:setter) }
      end

      context "called with value that can't be cast to Integer" do
        subject do
          type = described_class.new(10)
          type.value = [ 123 ]
          type
        end

        its(:value) { should be_nil }
        its(:incremented_by) { should eq(0) }
        its(:changed_by) { should eq(:setter) }
      end
    end
  end
end