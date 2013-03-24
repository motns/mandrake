require 'spec_helper'

describe Mandrake::Type::ObjectId do

  let(:object_id_string) {"514c5924e2fe024030000001"}

  let(:object_id) do
    BSON::ObjectId.from_string(object_id_string)
  end

  context "::initialize" do
    context "called with nil" do
      subject { described_class.new(nil) }
      its (:value) { should be_nil }
    end

    context 'called with a BSON::ObjectId' do
      subject { described_class.new(object_id) }
      its (:value) { should == object_id }
    end
  end


  context "#value" do
    context 'when value is a BSON::ObjectId' do
      subject { described_class.new(object_id) }
      its(:value) { should == object_id }
    end
  end


  context "#value=" do
    context 'when base value is nil' do
      context 'called with BSON::ObjectId' do
        subject do
          type = described_class.new(nil)
          type.value = object_id
          type
        end

        its(:value) { should == object_id }
      end

      context 'called with "514c5924e2fe024030000001" (valid ObjectId string)' do
        subject do
          type = described_class.new(nil)
          type.value = object_id_string
          type
        end

        its(:value) { should == object_id }
      end

      context 'called with "1a2b3c" (invalid ObjectId string)' do
        subject do
          type = described_class.new(nil)
          type.value = "1a2b3c"
          type
        end

        its(:value) { should be_nil }
      end
    end
  end
end