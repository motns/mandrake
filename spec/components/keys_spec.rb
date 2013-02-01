require 'spec_helper'

describe Mandrake::Keys do

  describe "::key" do

    context "when called with only the (required) name and type" do
      book_class = Class.new(TestBaseModel) do
        key :title, String
      end

      it "creates new key in Model" do
        book_class.schema.keys.should include(:title)
      end

      it "creates alias under the same name" do
        book_class.aliases[:title].should eq(:title)
      end

      it "sets the default to nil" do
        book_class.schema[:title][:default].should be_nil
      end

      it "sets the key as not required" do
        book_class.schema[:title][:required].should be_false
      end

      book = book_class.new

      it "creates a getter for key" do
        book.title.should be_nil
      end

      it "creates a setter for key" do
        book.title = "New title"
        book.title.should eq("New title")
      end
    end


    context "when called with extra option" do

      context ":as for setting an alias" do
        book_class = Class.new(TestBaseModel) do
          key :title, String, :as => :t
        end

        it "creates new key in Model" do
          book_class.schema.keys.should include(:title)
        end

        it "creates the defined alias" do
          book_class.aliases[:t].should eq(:title)
        end

        book = book_class.new

        it "creates a getter for key" do
          book.title.should be_nil
        end

        it "creates a getter for alias" do
          book.t.should be_nil
        end

        it "creates a setter for key" do
          book.title = "New title"
          book.title.should eq("New title")
        end

        it "creates a setter for alias" do
          book.t = "Updated title"
          book.title.should eq("Updated title")
        end
      end


      context ":default" do
        book_class = Class.new(TestBaseModel) do
          key :title, String, default: "My book"
        end

        it "sets the default value for key" do
          book_class.schema[:title][:default].should eq("My book")
        end
      end


      context ":required => true" do
        book_class = Class.new(TestBaseModel) do
          key :title, String, required: true
        end

        it "sets the key as required" do
          book_class.schema[:title][:required].should be_true
        end
      end


      context ":length as a Range" do
        book_class = Class.new(TestBaseModel) do
          key :title, String, length: 2..200
        end

        it "sets the length Range for the key" do
          book_class.schema[:title][:length].should eq(2..200)
        end
      end


      context ":length as an Integer" do
        book_class = Class.new(TestBaseModel) do
          key :title, String, length: 50
        end

        it "sets the maximum length for the key" do
          book_class.schema[:title][:length].should eq(50)
        end
      end


      context ":format option" do
        book_class = Class.new(TestBaseModel) do
          key :title, String, format: /\w+/
        end

        it "sets the format requirement on the key" do
          book_class.schema[:title][:format].should eq(/\w+/)
        end
      end
    end


    context "when called with the same name multiple times" do
      it "throws an exception" do
        expect {
          Class.new(TestBaseModel) do
            key :title, String
            key :title, String
          end
        }.to raise_error('Key "title" is already defined')
      end
    end


    context "when called with a name that's already used as an alias" do
      it "throws an exception" do
        expect {
          Class.new(TestBaseModel) do
            key :title, String, as: :t
            key :t, String
          end
        }.to raise_error('Key name "t" is already used as an alias for another field')
      end
    end


    context "when called with an alias that's already taken" do
      it "throws an exception" do
        expect {
          Class.new(TestBaseModel) do
            key :title, String, as: :t
            key :theme, String, as: :t
          end
        }.to raise_error('Alias "t" already taken')
      end
    end


    context "when called with an alias that's already used as a field name" do
      it "throws an exception" do
        expect {
          Class.new(TestBaseModel) do
            key :title, String, as: :t
            key :full_title, String, as: :title
          end
        }.to raise_error('Alias "title" is already used as a field name')
      end
    end
  end

end