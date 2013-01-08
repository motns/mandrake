require 'spec_helper'

describe Mandrake::Keys do

  context "defining a valid schema" do

    shared_examples "key creation" do |model_class, expected_keys|
      include_examples("base schema", model_class, expected_keys)
      include_examples("getters and setters", model_class, expected_keys)
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


    ############################################################################

    context "calling ::key only with required args" do
      book = Class.new do
        include Mandrake::Model
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
        include Mandrake::Model
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
        include Mandrake::Model
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
        include Mandrake::Model
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
            include Mandrake::Model

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
            include Mandrake::Model

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
            include Mandrake::Model

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
            include Mandrake::Model

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
            include Mandrake::Model

            key :title, String, as: :t, length: 30.2
          end
        }.to raise_error('Length option for "title" has to be an Integer or a Range')
      end
    end
  end

end