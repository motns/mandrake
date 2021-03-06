require 'spec_helper'

describe Mandrake::Type::Float do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
      its(:incremented_by) { should eq(0.0) }
      its(:changed_by) { should eq(:setter) }
    end

    context "called with 7.2" do
      subject { described_class.new(7.2) }
      its (:value) { should eq(7.2) }
      its(:incremented_by) { should eq(0.0) }
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
    context "when base value is 7.2" do
      context "called without arguments" do
        subject do
          type = described_class.new(7.2)
          type.increment
          type
        end

        its(:value) { should eq(8.2) }
        its(:incremented_by) { should eq(1.0) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with 1.6" do
        subject do
          type = described_class.new(7.2)
          type.increment(1.6)
          type
        end

        its(:value) { should eq(8.8) }
        its(:incremented_by) { should eq(1.6) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with -2.1" do
        subject do
          type = described_class.new(7.2)
          type.increment(-2.1)
          type
        end

        its(:value) { should eq(5.1) }
        its(:incremented_by) { should eq(-2.1) }
        its(:changed_by) { should eq(:modifier) }
      end

      context "called with 2" do
        subject { described_class.new(7.2) }

        it do
          expect {
            subject.increment(2)
          }.to raise_error('The increment has to be a Float, Fixnum given')
        end
      end

      context "called via #inc" do
        context "with 1.6" do
          subject do
            type = described_class.new(7.2)
            type.increment(1.6)
            type
          end

          its(:value) { should eq(8.8) }
          its(:incremented_by) { should eq(1.6) }
          its(:changed_by) { should eq(:modifier) }
        end
      end
    end
  end


  context "#increment and #value= combined" do
    context "when base value is 7.2" do
      subject { described_class.new(7.2) }

      context "first setting to 8.2 then incrementing by 1.1" do
        subject do
          type = described_class.new(7.2)
          type.value = 8.2
          type.increment(1.1)
          type
        end

        its(:value) { should be_within(0.1).of(9.3) }
        its(:incremented_by) { should be_within(0.1).of(1.1) }
        its(:changed_by) { should eq(:setter) }
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
      context "called with 13.4" do
        subject do
          type = described_class.new(10.0)
          type.value = 13.4
          type
        end

        its(:value) { should eq(13.4) }
        its(:incremented_by) { should eq(0.0) }
        its(:changed_by) { should eq(:setter) }
      end

      context 'called with "12.3"' do
        subject do
          type = described_class.new(10.0)
          type.value = "12.3"
          type
        end

        its(:value) { should eq(12.3) }
        its(:incremented_by) { should eq(0.0) }
        its(:changed_by) { should eq(:setter) }
      end

      context "called with value which can't be cast to Float" do
        subject do
          type = described_class.new(10.0)
          type.value = [ 12.3 ]
          type
        end

        its(:value) { should be_nil }
        its(:incremented_by) { should eq(0.0) }
        its(:changed_by) { should eq(:setter) }
      end
    end
  end
end