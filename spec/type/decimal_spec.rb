require 'spec_helper'

describe Mandrake::Type::Decimal do

  context "::initialize" do
    context "called with nil" do
      before do
        @attribute = described_class.new(nil)
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end
    end


    context "called with a BigDecimal" do
      before do
        @attribute = described_class.new(BigDecimal("7.2"))
      end

      it "sets the value to given BigDecimal" do
        @attribute.value.should eq(BigDecimal("7.2"))
      end
    end
  end


  context "::params" do
    context "returns hash" do
      it "including :in with a default of nil" do
        described_class.params.should include(:in)
        described_class.params[:in].should be_nil
      end
    end
  end


  context "#increment" do
    before do
      @attribute = described_class.new(BigDecimal("7.2"))
    end

    context "without arguments" do
      before do
        @attribute.increment
      end

      it "increments the value by 1.0" do
        @attribute.value.should eq(BigDecimal("8.2"))
      end

      it "shows that the value was incremented by 1.0" do
        @attribute.incremented_by.should eq(BigDecimal("1.0"))
      end
    end

    context "with positive BigDecimal" do
      before do
        @attribute.increment(BigDecimal("1.6"))
      end

      it "increments the value by given amount" do
        @attribute.value.should eq(BigDecimal("8.8"))
      end

      it "shows that the value was incremented by given amount" do
        @attribute.incremented_by.should eq(BigDecimal("1.6"))
      end
    end

    context "with negative BigDecimal" do
      before do
        @attribute.increment(BigDecimal("-2.1"))
      end

      it "decrements the value by given amount" do
        @attribute.value.should eq(BigDecimal("5.1"))
      end

      it "shows that the value was decremented by given amount" do
        @attribute.incremented_by.should eq(BigDecimal("-2.1"))
      end
    end


    context "with Integer" do
      before do
        @attribute.increment(2)
      end

      it "increments the value by given amount" do
        @attribute.value.should eq(BigDecimal("9.2"))
      end

      it "shows that the value was incremented by given amount" do
        @attribute.incremented_by.should eq(BigDecimal("2.0"))
      end
    end


    context "with Float (not recommended!)" do
      before do
        @attribute.increment(2.3)
      end

      it "increments the value by given amount" do
        @attribute.value.should eq(BigDecimal("9.5"))
      end

      it "shows that the value was incremented by given amount" do
        @attribute.incremented_by.should eq(BigDecimal("2.3"))
      end
    end


    context "with incompatible argument" do
      it "raises an error" do
        expect {
          @attribute.increment("aaa")
        }.to raise_error('The increment has to be a BigDecimal, Float or Integer - String given')
      end
    end


    context "through #inc alias" do
      before do
        @attribute.inc(BigDecimal("2.1"))
      end

      it "increments the value by given amount" do
        @attribute.value.should eq(BigDecimal("9.3"))
      end

      it "shows that the value was incremented by given amount" do
        @attribute.incremented_by.should eq(BigDecimal("2.1"))
      end
    end
  end


  context "#value" do
    before do
      @attribute = described_class.new(BigDecimal("3.2"))
    end

    it "returns the current value" do
      @attribute.value.should eq(BigDecimal("3.2"))
    end
  end


  context "#value=" do
    before do
      @attribute = described_class.new(BigDecimal("3.2"))
    end

    context "with a BigDecimal" do
      before do
        @attribute.value = BigDecimal("13.4")
      end

      it "sets the value to given BigDecimal" do
        @attribute.value.should eq(BigDecimal("13.4"))
      end

      it "shows no incrementing on the value" do
        @attribute.incremented_by.should eq(BigDecimal("0.0"))
      end
    end


    context "with an Integer" do
      before do
        @attribute.value = 13
      end

      it "sets the value to given BigDecimal" do
        @attribute.value.should eq(BigDecimal("13.0"))
      end

      it "shows no incrementing on the value" do
        @attribute.incremented_by.should eq(BigDecimal("0.0"))
      end
    end


    context "with a Float (not recommended!)" do
      before do
        @attribute.value = 13.4
      end

      it "sets the value to given BigDecimal" do
        @attribute.value.should eq(BigDecimal("13.4"))
      end

      it "shows no incrementing on the value" do
        @attribute.incremented_by.should eq(BigDecimal("0.0"))
      end
    end


    context "with an incompatible argument" do
      before do
        @attribute.value = "aaa"
      end

      it "sets the value to nil" do
        @attribute.value.should be_nil
      end

      it "shows no incrementing on the value" do
        @attribute.incremented_by.should eq(BigDecimal("0.0"))
      end
    end
  end

end