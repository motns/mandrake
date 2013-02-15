require 'spec_helper'

describe Mandrake::Type::String do

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
    end

    context 'called with "bazinga!"' do
      subject { described_class.new("bazinga!") }
      its (:value) { should eq("bazinga!") }
    end
  end


  context "::params" do
    it { described_class.params.should be_a(::Hash) }
    it { described_class.params.should include(:length) }
    it { described_class.params.should include(:format) }
    it("should default :length to 0..50") { described_class.params[:length].should eq(0..50) }
    it("should default :format to nil") { described_class.params[:format].should be_nil }
  end


  context "#value" do
    context 'when value is "Peter Parker"' do
      subject { described_class.new("Peter Parker") }
      it 'returns "Peter Parker"' do
        subject.value.should eq("Peter Parker")
      end
    end
  end


  context "#value=" do
    context 'when base value is "Peter Parker"' do
      subject { described_class.new("Peter Parker") }

      context 'called with "Bruce Wayne"' do
        before { subject.value = "Bruce Wayne" }
        its(:value) { should eq("Bruce Wayne") }
      end

      context 'called with 123' do
        before { subject.value = 123 }
        its(:value) { should eq("123") }
      end
    end
  end
end