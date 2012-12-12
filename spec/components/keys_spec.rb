require 'spec_helper'

describe Mandrake::Keys do

  context "defining a valid schema" do

    shared_examples "schema" do |model_class, expected_keys|
      expected_aliases = {}
      expected_keys.each {|k, v| expected_aliases[v[:alias]] = k}

      if expected_keys.length == 1
        key_text = "creates a new key"
        alias_text = "creates a new alias"
      else
        key_text = "creates all new keys"
        alias_text = "creates all new aliases"
      end

      it key_text do
        model_class.keys.should eq(expected_keys)
      end

      it alias_text do
        model_class.aliases.should eq(expected_aliases)
      end
    end


    context "calling ::key only with required args" do
      book = Class.new do
        include Mandrake::Document
        key :title, String
      end

      include_examples(
        "schema",
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
        "schema",
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
        "schema",
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
        "schema",
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

end