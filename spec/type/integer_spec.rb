require 'spec_helper'

describe Mandrake::Type::Integer do

  context "::initialize" do
    context "called with nil" do
      before do
        @attribute = described_class.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with an Integer" do
      before do
        @attribute = described_class.new(15)
      end

      it "sets the value to given Integer" do
        @attribute.value.should eq(15)
      end
    end


    context "called with a non-Integer" do
      before do
        @attribute = described_class.new("123")
      end

      it "casts the value into Integer" do
        @attribute.value.should eq(123)
      end
    end
  end


  context "::params" do
    context "returns hash" do
      it "including :min with a default of nil" do
        described_class.params.should include(:min)
        described_class.params[:min].should be_nil
      end

      it "including :max with a default of nil" do
        described_class.params.should include(:max)
        described_class.params[:max].should be_nil
      end
    end
  end


  context "#increment" do
    before do
      @int = described_class.new(10)
    end

    context "without arguments" do
      before do
        @int.increment
      end

      it "increments the value by 1" do
        @int.value.should eq(11)
      end

      it "shows that the value was incremented by 1" do
        @int.incremented_by.should eq(1)
      end
    end

    context "with positive Integer argument" do
      before do
        @int.increment(5)
      end

      it "increments the value by given amount" do
        @int.value.should eq(15)
      end

      it "shows that the value was incremented by given amount" do
        @int.incremented_by.should eq(5)
      end
    end

    context "with negative Integer argument" do
      before do
        @int.increment(-4)
      end

      it "decrements the value by given amount" do
        @int.value.should eq(6)
      end

      it "shows that the value was decremented by given amount" do
        @int.incremented_by.should eq(-4)
      end
    end

    context "with non-Integer argument" do
        it "raises an error" do
          expect {
            @int.increment(2.3)
          }.to raise_error('The increment has to be an Integer, Float given')
        end
      end
  end
end