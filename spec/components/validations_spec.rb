require 'spec_helper'

describe Mandrake::Validations do


  context "#valid?" do
    context "when there is a required key" do
      before(:all) do
        @book_class = Class.new(TestBaseModel) do
          key :title, String, required: true
        end
      end

      context "defined in the instance" do
        before do
          @book = @book_class.new({:title => "My book"})
        end

        it "returns true" do
          @book.valid?.should be_true
        end
      end

      context "not defined in the instance" do
        before do
          @book = @book_class.new
        end

        it "returns false" do
          @book.valid?.should be_false
        end
      end
    end
  end

end