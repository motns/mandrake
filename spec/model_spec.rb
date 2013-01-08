require 'spec_helper'

describe Mandrake::Model do
  context "instantiating a new model" do
    before do
      @book = Class.new do
        include Mandrake::Model
        key :title, String, :as => :t
        key :description, String, :as => :d
        key :author, String, :as => :a
      end
    end


    context "with an empty hash" do
      before do
        @doc = @book.new
      end

      it "instantiates all keys to their defaults" do
        @doc.title.should be_nil
        @doc.description.should be_nil
        @doc.author.should be_nil
      end

      it "lists all keys as new" do
        @doc.new_keys.should include(:title, :description, :author, :id)
      end

      it "lists no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting some of the values" do
      before do
        @doc = @book.new({
          t: 'My new book',
          d: "Just plain awesome"
        })
      end

      it "has the correct values for the keys set" do
        @doc.title.should eq('My new book')
        @doc.description.should eq("Just plain awesome")
      end

      it "instantiates the remaining keys to their defaults" do
        @doc.author.should be_nil
      end

      it "lists the missing key as new" do
        @doc.new_keys.should include(:author, :id)
      end

      it "lists no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting all of the values" do
      before do
        @doc = @book.new({
          _id: BSON::ObjectId.new,
          t: 'My new book',
          d: "Just plain awesome",
          a: "Some guy"
        })
      end

      it "has the correct values for the keys set" do
        @doc.title.should eq('My new book')
        @doc.description.should eq("Just plain awesome")
        @doc.author.should eq("Some guy")
      end

      it "lists no keys as new" do
        @doc.new_keys.should be_empty
      end

      it "lists no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash containing additional values" do
      before do
        @doc = @book.new({
          _id: BSON::ObjectId.new,
          t: 'My new book',
          d: "Just plain awesome",
          a: "Some guy",
          c: "random stuff"
        })
      end

      it "has the correct values for the keys set" do
        @doc.title.should eq('My new book')
        @doc.description.should eq("Just plain awesome")
        @doc.author.should eq("Some guy")
      end

      it "lists no keys as new" do
        @doc.new_keys.should be_empty
      end

      it "lists the extra key as removed" do
        @doc.removed_keys.should include(:c)
      end
    end


    context "with a hash setting all of the values by their key name" do
      before do
        @doc = @book.new({
          _id: BSON::ObjectId.new,
          title: 'My new book',
          description: "Just plain awesome",
          author: "Some guy"
        })
      end

      it "has the correct values for the keys set" do
        @doc.title.should eq('My new book')
        @doc.description.should eq("Just plain awesome")
        @doc.author.should eq("Some guy")
      end

      it "lists all keys as new" do
        @doc.new_keys.should include(:title, :author, :description)
      end

      it "lists no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting values both by their key name and their alias" do
      before do
        @doc = @book.new({
          _id: BSON::ObjectId.new,
          t: 'My new book2',
          title: 'My new book',
          d: "Just plain awesome2",
          description: "Just plain awesome",
          a: "Some guy2",
          author: "Some guy"
        })
      end

      it "has the values set via the aliases" do
        @doc.title.should eq('My new book2')
        @doc.description.should eq("Just plain awesome2")
        @doc.author.should eq("Some guy2")
      end

      it "lists no keys as new" do
        @doc.new_keys.should be_empty
      end

      it "lists the full keys as removed" do
        @doc.removed_keys.should include(:title, :description, :author)
      end
    end
  end

end