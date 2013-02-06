require 'spec_helper'

describe Mandrake::Validation do
  context "::initialize" do
    context "called with a valid Validator and single attribute name" do
      before(:all) do
        @validation = described_class.new(:Presence, :title)
      end

      it "sets the :validator_name" do
        @validation.validator_name.should eq(:Presence)
      end

      it "sets the :validator_class" do
        @validation.validator_class.should eq(Mandrake::Validator::Presence)
      end

      it "contains the given :attribute" do
        @validation.attributes.should include(:title)
      end
    end


    context "called with a valid Validator and multiple attribute names" do
      before(:all) do
        @validation = described_class.new(:ValueMatch, :password, :password_confirm)
      end

      it "sets the :validator_name" do
        @validation.validator_name.should eq(:ValueMatch)
      end

      it "sets the :validator_class" do
        @validation.validator_class.should eq(Mandrake::Validator::ValueMatch)
      end

      it "contains all the attributes" do
        @validation.attributes.should include(:password)
        @validation.attributes.should include(:password_confirm)
      end
    end


    context "called with validator name that can't be converted to Symbol" do
      it "raises an error" do
        expect {
          described_class.new(String, :vehicle)
        }.to raise_error("Validator name should be provided as a Symbol, Class given")
      end
    end


    context "called with validator that doesn't exist" do
      it "raises an error" do
        expect {
          described_class.new(:Batmobil, :vehicle)
        }.to raise_error("Unknown validator: Batmobil")
      end
    end


    context "called with attribute name that can't be converted to Symbol" do
      it "raises an error" do
        expect {
          described_class.new(:Presence, 123)
        }.to raise_error("Attribute name has to be a Symbol, Fixnum given")
      end
    end
  end


  context "#run" do
    before(:all) do
      @user = Class.new(TestBaseModel) do
        key :title, :String
        key :password, :String
        key :password_confirm, :String
      end
    end


    context "with a single-field validator with no parameters" do
      before(:all) do
        @validation = described_class.new(:Presence, :title)
      end

      context "and a document with a valid attribute" do
        before(:all) do
          @doc = @user.new({:title => "Bruce Wayne"})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid attribute" do
        before(:all) do
          @doc = @user.new
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for attribute" do
          @doc.failed_validators.list.should include(:title)
          @doc.failed_validators.list[:title].should include({
            :validator => :Presence,
            :error_code => :missing,
            :message => "must be provided"
          })
        end
      end
    end


    context "with a single-field validator that takes parameters" do
      before(:all) do
        @validation = described_class.new(:Length, :title, length: 0..12)
      end

      context "and a document with a valid attribute" do
        before(:all) do
          @doc = @user.new({:title => "Bruce Wayne"})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid attribute" do
        before(:all) do
          @doc = @user.new({:title => "The incredible Spider Man"})
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for attribute" do
          @doc.failed_validators.list.should include(:title)
          @doc.failed_validators.list[:title].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be shorter than 12 characters"
          })
        end
      end
    end


    context "with a multi-field validator" do
      before(:all) do
        @validation = described_class.new(:ValueMatch, :password, :password_confirm)
      end

      context "and a document with valid attributes" do
        before(:all) do
          @doc = @user.new({:password => "mypass", :password_confirm => "mypass"})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid attribute" do
        before(:all) do
          @doc = @user.new({:password => "mypass", :password_confirm => "notmypass"})
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for the model" do
          @doc.failed_validators.list.should include(:model)
          @doc.failed_validators.list[:model].should include({
            :validator => :ValueMatch,
            :attributes => [:password, :password_confirm],
            :error_code => :no_match,
            :message => "must be the same"
          })
        end
      end
    end
  end
end