require 'spec_helper'

describe Mandrake::Type::Float do

  context "::initialize" do
    context "called with nil" do
      before do
        @attribute = described_class.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with a Float" do
      before do
        @attribute = described_class.new(7.2)
      end

      it "sets the value to given Float" do
        @attribute.value.should eq(7.2)
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
      @attribute = described_class.new(7.2)
    end

    context "without arguments" do
      before do
        @attribute.increment
      end

      it "increments the value by 1.0" do
        @attribute.value.should eq(8.2)
      end

      it "shows that the value was incremented by 1.0" do
        @attribute.incremented_by.should eq(1.0)
      end
    end

    context "with positive Float" do
      before do
        @attribute.increment(1.6)
      end

      it "increments the value by given amount" do
        @attribute.value.should eq(8.8)
      end

      it "shows that the value was incremented by given amount" do
        @attribute.incremented_by.should eq(1.6)
      end
    end

    context "with negative Float" do
      before do
        @attribute.increment(-2.1)
      end

      it "decrements the value by given amount" do
        @attribute.value.should eq(5.1)
      end

      it "shows that the value was decremented by given amount" do
        @attribute.incremented_by.should eq(-2.1)
      end
    end

    context "with non-Float" do
      it "raises an error" do
        expect {
          @attribute.increment(2)
        }.to raise_error('The increment has to be a Float, Fixnum given')
      end
    end

    context "through #inc alias" do
      before do
        @attribute.inc(2.1)
      end

      it "increments the value by given amount" do
        @attribute.value.should eq(9.3)
      end

      it "shows that the value was incremented by given amount" do
        @attribute.incremented_by.should eq(2.1)
      end
    end
  end


  context "#value" do
    before do
      @attribute = described_class.new(3.2)
    end

    it "returns the current value" do
      @attribute.value.should eq(3.2)
    end
  end


  context "#value=" do
    before do
      @attribute = described_class.new(3.2)
    end

    context "called with a Float" do
      before do
        @attribute.value = 13.4
      end

      it "sets the value to given Float" do
        @attribute.value.should eq(13.4)
      end

      it "shows no incrementing on the value" do
        @attribute.incremented_by.should eq(0)
      end
    end


    context "called with a non-Float" do
      before do
        @attribute = described_class.new("12.3")
      end

      it "casts the value into Float" do
        @attribute.value.should eq(12.3)
      end

      it "shows no incrementing on the value" do
        @attribute.incremented_by.should eq(0)
      end
    end
  end

end