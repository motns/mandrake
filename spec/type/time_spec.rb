require 'spec_helper'

describe Mandrake::Type::Time do
  before(:all) { @date_string = "2012-03-05 12:15:30" }
  let(:time) { Time.parse(@date_string) }

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
    end

    context "called with Time" do
      subject { described_class.new(time) }
      its (:value) { should eq(time) }
    end
  end


  context "::params" do
    it { described_class.params.should be_a(::Hash) }
    it { described_class.params.should include(:in) }
    it("should default :in to nil") { described_class.params[:in].should be_nil }
  end


  context "#value" do
    context "when value is Time" do
      subject { described_class.new(time) }
      its(:value) { should eq(time) }
    end
  end


  context "#value=" do
    context 'when base value is nil' do
      subject(:type) { described_class.new(nil) }

      context "called with Time" do
        before { type.value = time }
        its(:value) { should eq(time) }
      end

      context "called with 1362507690" do
        before { type.value = 1362507690 }
        its(:value) { should eq(::Time.at(1362507690)) }
      end

      context "called with 1362507690.456" do
        before { type.value = 1362507690.456 }
        its(:value) { should eq(::Time.at(1362507690.456)) }
      end

      context 'called with "2012-03-05 12:15:30"' do
        before { type.value = "2012-03-05 12:15:30" }
        its(:value) { should eq(::Time.parse("2012-03-05 12:15:30")) }
      end

      context "called with TrueClass" do
        before { type.value = true }
        its(:value) { should be_nil }
      end
    end
  end
end