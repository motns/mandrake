require 'spec_helper'
require 'set'

# @todo Most of these examples should be shared with Array
describe Mandrake::Type::Set do

  context "::initialize" do
    context "when called with nil" do
      subject { described_class.new(nil) }
      its(:value) { should be_nil }
      its(:added) { should be_empty }
      its(:removed) { should be_empty }
    end

    context "when called with Set {1, 2, 3}" do
      subject { described_class.new([1, 2, 3].to_set) }
      its(:value) { should eq([1, 2, 3].to_set) }
      its(:added) { should be_empty }
      its(:removed) { should be_empty }
    end
  end


  context "#value" do
    context "when the value is Set {2, 3, 4}" do
      subject { described_class.new([2, 3, 4].to_set) }
      it "returns Set {2, 3, 4}" do
        subject.value.should eq([2, 3, 4].to_set)
      end
    end
  end


  context "#value=" do
    context "when called with Set {1, 2, 3}" do
      subject do
        type = described_class.new(nil)
        type.value = [1, 2, 3].to_set
        type
      end

      its(:value) { should eq([1, 2, 3].to_set) }
      its(:added) { should be_empty }
      its(:removed) { should be_empty }
      its(:changed_by) { should eq(:setter) }
    end

    context "when called with [4, 5, 6]" do
      subject do
        type = described_class.new(nil)
        type.value = [4, 5, 6]
        type
      end

      its(:value) { should eq([4, 5, 6].to_set) }
      its(:added) { should be_empty }
      its(:removed) { should be_empty }
      its(:changed_by) { should eq(:setter) }
    end

    context 'when called with a non-Set - "blurb"' do
      subject do
        type = described_class.new(nil)
        type.value = "blurb"
        type
      end

      its(:value) { should be_nil }
      its(:added) { should be_empty }
      its(:removed) { should be_empty }
      its(:changed_by) { should eq(:setter) }
    end
  end


  context "#push" do
    context "with a base value of nil" do
      context "when called with one argument: 5" do
        subject do
          type = described_class.new(nil)
          type.push(5)
          type
        end

        its(:value) { should include(5) }
        its(:added) { should include(5) }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:setter) }
      end

      context "when called with multiple arguments: 6, 8" do
        subject do
          type = described_class.new(nil)
          type.push(6, 8)
          type
        end

        its(:value) { should include(6, 8) }
        its(:added) { should include(6, 8) }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:setter) }
      end

      context "when called with the same argument (5) multiple times" do
        subject do
          type = described_class.new(nil)
          type.push(5)
          type.push(5)
          type.push(5)
          type
        end

        its(:value) { should include(5) }
        its(:added) { should include(5) }
        its(:added) { should have(1).item }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:setter) }
      end
    end


    context "with a base value of Set {1, 2, 3}" do
      context "when called with one argument: 5" do
        subject do
          type = described_class.new([1, 2, 3].to_set)
          type.push(5)
          type
        end

        its(:value) { should include(5) }
        its(:added) { should include(5) }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:modifier) }
      end

      context "when called with an existing element: 3" do
        subject do
          type = described_class.new([1, 2, 3].to_set)
          type.push(3)
          type
        end

        its(:value) { should include(3) }
        its(:added) { should be_empty }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:setter) }
      end
    end
  end


  context "#pull" do
    context "with a base value of Set {5, 6, 7}" do
      context "when called with one argument: 5" do
        subject do
          type = described_class.new([5, 6, 7].to_set)
          type.pull(5)
          type
        end

        before { subject.pull(5) }
        its(:value) { should_not include(5) }
        its(:removed) { should include(5) }
        its(:added) { should be_empty }
        its(:changed_by) { should eq(:modifier) }
      end

      context "when called with multiple arguments: 6, 7" do
        subject do
          type = described_class.new([5, 6, 7].to_set)
          type.pull(6, 7)
          type
        end

        its(:value) { should_not include(6, 7) }
        its(:removed) { should include(6, 7) }
        its(:added) { should be_empty }
        its(:changed_by) { should eq(:modifier) }
      end
    end
  end


  context "#push and #pull combined" do
    context "with a base value of nil" do
      context "first adding and then removing: 5" do
        subject do
          type = described_class.new(nil)
          type.push(5)
          type.pull(5)
          type
        end

        its(:value) { should be_empty }
        its(:added) { should be_empty }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:setter) }
      end
    end
  end


  context "#push and #value= combined" do
    context "with a base value of Set {1, 2, 3}" do
      context "first setting to Set {4, 5} then pushing 6" do
        subject do
          type = described_class.new([1, 2, 3].to_set)
          type.value = [4, 5].to_set
          type.push(6)
          type
        end

        its(:value) { should eq([4, 5, 6].to_set) }
        its(:added) { should eq([6]) }
        its(:removed) { should be_empty }
        its(:changed_by) { should eq(:setter) }
      end
    end
  end
end