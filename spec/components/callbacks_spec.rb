require 'spec_helper'

describe Mandrake::Callbacks do
  before(:each) do
    @book_class = Class.new(TestBaseModel) do
      key :title, :String
    end
  end


  context "when a Model is initialized" do
    before(:each) do
      @listener = mock
      @listener.stub(:after_initialize) {|doc| true }
      @book_class.after_initialize @listener
    end

    it "fires the after_initialize callback" do
      @listener.should_receive(:after_initialize).once
      @book_class.new
    end
  end


  context "when a Model attribute is changed" do
    before(:each) do
      @listener = mock
      @listener.stub(:after_attribute_change) {|doc| true }
      @book_class.after_attribute_change @listener
    end

    it "fires the after_attribute_change callback" do
      @listener.should_receive(:after_attribute_change).once
      @book = @book_class.new
      @book.title = "New title"
    end
  end
end