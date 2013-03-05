require 'spec_helper'

describe Mandrake::Validations do
  context "#valid?" do
    context "when there is a single key" do
      context "that is required" do
        before(:all) do
          @book_class = Class.new(TestBaseModel) do
            key :title, :String, required: true, length: 1..10
          end
        end

        context "and is present and valid" do
          before(:all) do
            @book = @book_class.new({:title => "My book"})
          end

          it "returns true" do
            @book.valid?.should be_true
          end

          it "adds no failed validators" do
            @book.failed_validators.list.should be_empty
          end
        end


        context "and is empty and would also fail length validator" do
          before(:all) do
            @book = @book_class.new({:title => ""})
          end

          it "returns false" do
            @book.valid?.should be_false
          end

          it "adds :Presence to failed validators" do
            @book.failed_validators.list.should include(:title)
            @book.failed_validators.list[:title].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end

          it "doesn't add :Length to failed validators" do
            @book.failed_validators.list[:title].should_not include({
              :validator => :Length,
              :error_code => :short,
              :message => "has to be longer than 1 characters"
            })
          end
        end
      end


      context "that is not required" do
        before(:all) do
          @book_class = Class.new(TestBaseModel) do
            key :title, :String, length: 1..10
          end
        end

        context "and is not present" do
          before(:all) do
            @book = @book_class.new
          end

          it "returns true" do
            @book.valid?.should be_true
          end

          it "adds no failed validators" do
            @book.failed_validators.list.should be_empty
          end
        end
      end
    end


    context "when there are multiple keys" do
      before(:all) do
        @book_class = Class.new(TestBaseModel) do
          key :title, :String, required: true
          key :author, :String, length: 1..10
          key :description, :String, length: 1..10
        end
      end

      context "and they are all valid" do
        before(:all) do
          @book = @book_class.new({
            :title => "My title",
            :author => "Me",
            :description => "My book"
          })
        end

        it "returns true" do
          @book.valid?.should be_true
        end

        it "adds no failed validators" do
          @book.failed_validators.list.should be_empty
        end
      end


      context "and some are invalid" do
        before(:all) do
          @book = @book_class.new({
            :title => "My title",
            :author => "William Shakespeare",
            :description => ""
          })
        end

        it "returns false" do
          @book.valid?.should be_false
        end

        it "adds failed validator for invalid field" do
          @book.failed_validators.list.should include(:author)
          @book.failed_validators.list[:author].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 10 characters or less"
          })
        end

        it "doesn't add failed validators for valid fields" do
          @book.failed_validators.list.should_not include(:title)
          @book.failed_validators.list.should_not include(:description)
        end
      end


      context "and all are invalid" do
        before(:all) do
          @book = @book_class.new({
            :title => "",
            :author => "William Shakespeare",
            :description => "My amazing book"
          })
        end

        it "returns false" do
          @book.valid?.should be_false
        end

        it "adds failed validator for all fields" do
          @book.failed_validators.list.should include(:title)
          @book.failed_validators.list.should include(:author)
          @book.failed_validators.list.should include(:description)

          @book.failed_validators.list[:title].should include({
            :validator => :Presence,
            :error_code => :empty,
            :message => "cannot be empty"
          })

          @book.failed_validators.list[:author].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 10 characters or less"
          })

          @book.failed_validators.list[:description].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 10 characters or less"
          })
        end
      end
    end


    context "when there is a model validator" do
      before(:all) do
        @book_class = Class.new(TestBaseModel) do
          key :password, :String, required: true
          key :password_confirm, :String, required: true

          validate :ValueMatch, :password, :password_confirm
        end
      end

      context "and all validators pass" do
        before(:all) do
          @book = @book_class.new({
            :password => "mypass",
            :password_confirm => "mypass"
          })
        end

        it "returns true" do
          @book.valid?.should be_true
        end

        it "adds no failed validators" do
          @book.failed_validators.list.should be_empty
        end
      end


      context "and one of the attribute validators fails" do
        before(:all) do
          @book = @book_class.new({
            :password => "mypass",
            :password_confirm => ""
          })
        end

        it "returns false" do
          @book.valid?.should be_false
        end

        it "adds failed validator for invalid field" do
          @book.failed_validators.list.should include(:password_confirm)
          @book.failed_validators.list[:password_confirm].should include({
            :validator => :Presence,
            :error_code => :empty,
            :message => "cannot be empty"
          })
        end

        it "doesn't add failed validator for valid field" do
          @book.failed_validators.list.should_not include(:password)
        end

        it "doesn't run model validator" do
          @book.failed_validators.list.should_not include(:model)
        end
      end


      context "and the attribute validators pass, but the model validator fails" do
        before(:all) do
          @book = @book_class.new({
            :password => "mypass",
            :password_confirm => "mypass2"
          })
        end

        it "returns false" do
          @book.valid?.should be_false
        end

        it "adds failed validator for model validator" do
          @book.failed_validators.list.should include(:model)
          @book.failed_validators.list[:model].should include({
            :validator => :ValueMatch,
            :attributes => [:password, :password_confirm],
            :error_code => :no_match,
            :message => "must be the same"
          })
        end

        it "doesn't add failed validator for attributes" do
          @book.failed_validators.list.should_not include(:password)
          @book.failed_validators.list.should_not include(:password_confirm)
        end
      end
    end
  end


  context "#validate" do
    context "when called with a Validator that takes no parameters" do
      before(:all) do
        @book_class = Class.new(TestBaseModel)
        @validation = @book_class.validate :Presence, :title
      end

      it "adds new Validation to the main validation chain" do
        @book_class.validation_chain.items.should include(@validation)
      end
    end


    context "when called with a Validator that takes parameters" do
      before(:all) do
        @book_class = Class.new(TestBaseModel)
        @validation = @book_class.validate :Length, :title, length: 0..15
      end

      it "adds new Validation to the main validation chain" do
        @book_class.validation_chain.items.should include(@validation)
      end
    end
  end


  context "#chain" do
    context "when called with a block" do
      before(:all) do
        @book_class = Class.new(TestBaseModel)
        @validation = validation = Mandrake::Validation.new(:Presence, :title)

        @chain2 = @book_class.chain(if_present: :title) do
          add validation
        end
      end

      it "adds new ValidationChain to the main validation chain" do
        @book_class.validation_chain.items.should include(@chain2)
      end

      it "passes the block to new ValidationChain" do
        @chain2.items.should include(@validation)
      end
    end
  end


  context "#if_present" do
    context "when called with a block" do
      before(:all) do
        @book_class = Class.new(TestBaseModel)
        @validation = validation = Mandrake::Validation.new(:Presence, :title)

        @chain2 = @book_class.if_present :title do
          add validation
        end
      end

      it "adds new ValidationChain to the main validation chain" do
        @book_class.validation_chain.items.should include(@chain2)
      end

      it "sets the :if_present conditional on the new ValidationChain" do
        @chain2.conditions.should include({
          :validator => Mandrake::Validator::Presence,
          :attribute => :title
        })
      end

      it "passes the block to the new ValidationChain" do
        @chain2.items.should include(@validation)
      end
    end
  end


  context "#if_absent" do
    context "when called with a block" do
      before(:all) do
        @book_class = Class.new(TestBaseModel)
        @validation = validation = Mandrake::Validation.new(:Presence, :username)

        @chain2 = @book_class.if_absent :title do
          add validation
        end
      end

      it "adds new ValidationChain to the chain" do
        @book_class.validation_chain.items.should include(@chain2)
      end

      it "sets the :if_absent conditional on the chain" do
        @chain2.conditions.should include({
          :validator => Mandrake::Validator::Absence,
          :attribute => :title
        })
      end

      it "passes the block to new ValidationChain" do
        @chain2.items.should include(@validation)
      end
    end
  end

end