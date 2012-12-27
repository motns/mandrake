require 'spec_helper'

describe Mandrake::Keys do

  context "defining a valid schema" do

    shared_examples "key creation" do |model_class, expected_keys|
      include_examples("base schema", model_class, expected_keys)
      include_examples("getters and setters", model_class, expected_keys)
      include_examples("change tracking", model_class, expected_keys)
    end


    shared_examples "base schema" do |model_class, expected_keys|

      keys_to_check = expected_keys.clone
      keys_to_check[:id] = {
        :type => BSON::ObjectId,
        :alias => :_id,
        :required => false,
        :default => nil,
        :length => nil,
        :format => nil
      }

      expected_aliases = {}
      keys_to_check.each {|k, v| expected_aliases[v[:alias]] = k}

      model_object = model_class.new

      if keys_to_check.length == 1
        key_text = "creates a new key"
        alias_text = "creates a new alias"
      else
        key_text = "creates all new keys"
        alias_text = "creates all new aliases"
      end

      it key_text do
        model_class.keys.should eq(keys_to_check)
      end

      it alias_text do
        model_class.aliases.should eq(expected_aliases)
      end
    end


    shared_examples "getters and setters" do |model_class, expected_keys|

      model_object = model_class.new

      it "creates getters and setters for each key" do
        model_class.keys.each do |k, v|
          val = "test#{rand(1..1000)}"
          model_object.public_send "#{k}=".to_sym, val

          model_object.public_send(k).should eq(val)
        end
      end

      it "creates getters and setters for each alias" do
        model_class.aliases.each do |k, v|
          val = "test#{rand(1..1000)}"
          model_object.public_send "#{k}=".to_sym, val

          model_object.public_send(k).should eq(val)
        end
      end
    end


    shared_examples "change tracking" do |model_class, expected_keys|

      model_values = {}
      expected_keys.each {|k, v| model_values[k] = "oldvalue#{rand(1..1000)}"}

      model_object1 = model_class.new(model_values)

      it "creates change tracker for the whole document" do
        model_object1.changed?.should be_false
        model_object1.changes.should be_nil

        k = model_object1.keys.keys.first
        new_val = "test#{rand(1..1000)}"
        old_val = model_object1.public_send(k)
        model_object1.public_send "#{k}=".to_sym, new_val

        model_object1.changed?.should be_true
        model_object1.changed.should include(k)
        model_object1.changes.should eq({k => [old_val, new_val]})
      end


      model_object2 = model_class.new(model_values)

      it "creates change tracker for each individual key" do
        model_class.keys.each do |k, v|
          new_val = "test#{rand(1..1000)}"
          old_val = model_object2.public_send(k)

          # Pre-change
          model_object2.public_send("#{k}_changed?").should eq(false)
          model_object2.public_send("#{k}_change").should be_nil
          model_object2.public_send("#{k}_was").should be_nil

          model_object2.public_send "#{k}=".to_sym, new_val

          # Post-change
          model_object2.public_send("#{k}_changed?").should eq(true)
          model_object2.public_send("#{k}_change").should eq([old_val, new_val])
          model_object2.public_send("#{k}_was").should eq(old_val)
        end
      end
    end


    ############################################################################

    context "calling ::key only with required args" do
      book = Class.new do
        include Mandrake::Document
        key :title, String
      end

      include_examples(
        "key creation",
        book,
        {
          :title => {
            :type => String,
            :alias => :title,
            :required => false,
            :default => nil,
            :length => nil,
            :format => nil
          }
        }
      )
    end


    context "calling ::key with :as for setting alias" do
      book = Class.new do
        include Mandrake::Document
        key :title, String, :as => :t
      end

      include_examples(
        "key creation",
        book,
        {
          :title => {
            :type => String,
            :alias => :t,
            :required => false,
            :default => nil,
            :length => nil,
            :format => nil
          }
        }
      )
    end


    context "calling ::key with optional :length and :format" do
      book = Class.new do
        include Mandrake::Document
        key :title, String, required: true, length: 2..200, format: /\w+/
      end

      include_examples(
        "key creation",
        book,
        {
          :title => {
            :type => String,
            :alias => :title,
            :required => true,
            :default => nil,
            :length => 2..200,
            :format => /\w+/
          }
        }
      )
    end


    context "calling ::key multiple times" do
      book = Class.new do
        include Mandrake::Document
        key :title, String, required: true, length: 2..200, format: /\w+/
        key :description, String, as: :d, required: false, length: 500
      end

      include_examples(
        "key creation",
        book,
        {
          :title => {
            :type => String,
            :alias => :title,
            :required => true,
            :default => nil,
            :length => 2..200,
            :format => /\w+/
          },
          :description => {
            :type => String,
            :alias => :d,
            :required => false,
            :default => nil,
            :length => 500,
            :format => nil
          }
        }
      )
    end
  end


  ##############################################################################
  ##############################################################################

  context "defining an invalid schema" do

    context "calling ::key with the same name multiple times" do
      it "throws an exception" do
        expect {
          Class.new do
            include Mandrake::Document

            key :title, String
            key :title, String
          end
        }.to raise_error('Key "title" is already defined')
      end
    end


    context "calling ::key with a name that's already used as an alias" do
      it "throws an exception" do
        expect {
          Class.new do
            include Mandrake::Document

            key :title, String, as: :t
            key :t, String
          end
        }.to raise_error('Key name "t" is already used as an alias for another field')
      end
    end


    context "calling ::key with an alias that's already taken" do
      it "throws an exception" do
        expect {
          Class.new do
            include Mandrake::Document

            key :title, String, as: :t
            key :theme, String, as: :t
          end
        }.to raise_error('Alias "t" already taken')
      end
    end


    context "calling ::key with an alias that's already used as a field name" do
      it "throws an exception" do
        expect {
          Class.new do
            include Mandrake::Document

            key :title, String, as: :t
            key :full_title, String, as: :title
          end
        }.to raise_error('Alias "title" is already used as a field name')
      end
    end


    context "calling ::key with a :length option that's not Integer or Range" do
      it "throws an exception" do
        expect {
          Class.new do
            include Mandrake::Document

            key :title, String, as: :t, length: 30.2
          end
        }.to raise_error('Length option for "title" has to be an Integer or a Range')
      end
    end
  end


  ##############################################################################
  ##############################################################################

  context "instantiating a new document" do
    before do
      @book = Class.new do
        include Mandrake::Document
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