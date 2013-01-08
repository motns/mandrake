require 'spec_helper'

describe Mandrake::Dirty do

  before do
    @book_class = Class.new do
      include Mandrake::Model
      key :title, String, :as => :t
    end
  end

  let(:book) do
    @book_class.new(title: "Old title")
  end


  describe "#changed?" do
    context "with a new Model instance" do
      it "returns false" do
        book.changed?.should be_false
      end
    end

    context "when an attribute is updated" do
      before do
        book.title = "New title"
      end

      it "returns true" do
        book.changed?.should be_true
      end
    end
  end


  describe "#changed" do
    context "with a new Model instance" do
      it "returns an empty array" do
        book.changed.should eq([])
      end
    end

    context "when an attribute is updated" do
      before do
        book.title = "New title"
      end

      it "returns an array of changed attributes" do
        book.changed.should eq([:title])
      end
    end
  end


  describe "#changes" do
    context "with a new Model instance" do
      it "returns nil" do
        book.changes.should be_nil
      end
    end

    context "when an attribute is updated" do
      before do
        book.title = "New title"
      end

      it "returns a hash with {:name => [old_value, new_value]}" do
        book.changes.should eq({
          :title => ["Old title", "New title"]
        })
      end
    end
  end


  describe "#attribute_changed?" do
    context "when the attribute was just initialized" do
      it "returns false when called directly" do
        book.attribute_changed?(:title).should be_false
      end

      it "returns false when called via #(name)_changed? shortcut" do
        book.title_changed?.should be_false
      end
    end


    context "when the attribute is updated" do
      before do
        book.title = "New title"
      end

      it "returns true when called directly" do
        book.attribute_changed?(:title).should be_true
      end

      it "returns true when called via #(name)_changed? shortcut" do
        book.title_changed?.should be_true
      end
    end
  end


  describe "#attribute_change" do
    context "when the attribute was just initialized" do
      it "returns nil when called directly" do
        book.attribute_change(:title).should be_nil
      end

      it "returns nil when called via #(name)_change shortcut" do
        book.title_change.should be_nil
      end
    end


    context "when the attribute is updated" do
      before do
        book.title = "New title"
      end

      it "returns [old_value, new_value] when called directly" do
        book.attribute_change(:title).should eq(["Old title", "New title"])
      end

      it "returns [old_value, new_value] when called via #(name)_change shortcut" do
        book.title_change.should eq(["Old title", "New title"])
      end
    end
  end


  describe "#attribute_was" do
    context "when the attribute was just initialized" do
      it "returns nil when called directly" do
        book.attribute_was(:title).should be_nil
      end

      it "returns nil when called via #(name)_was shortcut" do
        book.title_was.should be_nil
      end
    end


    context "when the attribute is updated" do
      before do
        book.title = "New title"
      end

      it "returns old value when called directly" do
        book.attribute_was(:title).should eq("Old title")
      end

      it "returns old value when called via #(name)_was shortcut" do
        book.title_was.should eq("Old title")
      end
    end
  end
end