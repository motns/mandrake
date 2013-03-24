require 'spec_helper'

describe Mandrake::Validations do
  context "#valid?" do
    context "with any Model" do
      before(:each) do
        @book_class = Class.new(TestBaseModel) do
          key :title, :String
        end
      end

      context "when called" do
        before(:each) do
          @listener = mock
          @listener.stub(:before_validation) {|doc| true }
          @listener.stub(:after_validation) {|doc| true }
          @book_class.before_validation @listener
          @book_class.after_validation @listener
        end

        it "fires the before_validation callback" do
          @listener.should_receive(:before_validation).once
          @book = @book_class.new
          @book.valid?
        end

        it "fires the after_validation callback" do
          @listener.should_receive(:after_validation).once
          @book = @book_class.new
          @book.valid?
        end
      end
    end


    context "with a single key" do
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

          it "returns true on second run" do
            @book.valid?.should be_true
          end

          context "when the value is changed to be invalid" do
            before(:all) { @book.title = "" }
            it("returns false") { @book.valid?.should be_false }

            context "and then back to valid again" do
              before(:all) { @book.title = "My title" }
              it("returns true") { @book.valid?.should be_true }
            end
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
            @book.failed_validators.list.should include(:attribute)
            @book.failed_validators.list[:attribute].should include(:title)
            @book.failed_validators.list[:attribute][:title].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end

          it "doesn't add :Length to failed validators" do
            @book.failed_validators.list[:attribute][:title].should_not include({
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


    context "with multiple keys" do
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
          @book.failed_validators.list.should include(:attribute)
          @book.failed_validators.list[:attribute].should include(:author)
          @book.failed_validators.list[:attribute][:author].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 10 characters or less"
          })
        end

        it "doesn't add failed validators for valid fields" do
          @book.failed_validators.list[:attribute].should_not include(:title)
          @book.failed_validators.list[:attribute].should_not include(:description)
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
          @book.failed_validators.list.should include(:attribute)
          @book.failed_validators.list[:attribute].should include(:title)
          @book.failed_validators.list[:attribute].should include(:author)
          @book.failed_validators.list[:attribute].should include(:description)

          @book.failed_validators.list[:attribute][:title].should include({
            :validator => :Presence,
            :error_code => :empty,
            :message => "cannot be empty"
          })

          @book.failed_validators.list[:attribute][:author].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 10 characters or less"
          })

          @book.failed_validators.list[:attribute][:description].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 10 characters or less"
          })
        end
      end
    end


    context "when there is a model validator" do
      before(:all) do
        @user_class = Class.new(TestBaseModel) do
          key :password, :String, required: true
          key :password_confirm, :String, required: true

          validate :ValueMatch, :password, :password_confirm
        end
      end

      context "and all validators pass" do
        before(:all) do
          @user = @user_class.new({
            :password => "mypass",
            :password_confirm => "mypass"
          })
        end

        it "returns true" do
          @user.valid?.should be_true
        end

        it "adds no failed validators" do
          @user.failed_validators.list.should be_empty
        end
      end


      context "and one of the attribute validators fails" do
        before(:all) do
          @user = @user_class.new({
            :password => "mypass",
            :password_confirm => ""
          })
        end

        it "returns false" do
          @user.valid?.should be_false
        end

        it "adds failed validator for invalid field" do
          @user.failed_validators.list.should include(:attribute)
          @user.failed_validators.list[:attribute].should include(:password_confirm)
          @user.failed_validators.list[:attribute][:password_confirm].should include({
            :validator => :Presence,
            :error_code => :empty,
            :message => "cannot be empty"
          })
        end

        it "doesn't add failed validator for valid field" do
          @user.failed_validators.list[:attribute].should_not include(:password)
        end

        it "doesn't run model validator" do
          @user.failed_validators.list.should_not include(:model)
        end
      end


      context "and the attribute validators pass, but the model validator fails" do
        before(:all) do
          @user = @user_class.new({
            :password => "mypass",
            :password_confirm => "mypass2"
          })
        end

        it "returns false" do
          @user.valid?.should be_false
        end

        it "adds failed validator for model validator" do
          @user.failed_validators.list.should include(:model)
          @user.failed_validators.list[:model].should include({
            :validator => :ValueMatch,
            :attributes => [:password, :password_confirm],
            :error_code => :no_match,
            :message => "must be the same"
          })
        end

        it "doesn't add failed validator for attributes" do
          @user.failed_validators.list.should_not include(:attribute)
        end
      end
    end


    context "when there is an embedded Model" do
      before(:all) do
        @book_class = Class.new(TestBaseDoc) do
          key :title, :String, required: true
        end

        @author_class = Class.new(TestBaseModel) do
          key :name, :String, required: true
        end

        @book_class.embed_one @author_class, :Author
      end


      context "and both Models are valid" do
        before(:all) do
          @book = @book_class.new({
            :title => "Being Batman",
            :Author => {
              :name => "Bruce Wayne"
            }
          })
        end

        it("returns true") { @book.valid?.should be_true }

        context "failed_validators" do
          it { @book.failed_validators.list.should be_empty }
        end
      end


      context "and the main Model is invalid" do
        before(:all) do
          @book = @book_class.new({
            :title => "",
            :Author => {
              :name => "Bruce Wayne"
            }
          })
        end

        it("returns false") { @book.valid?.should be_false }

        context "failed_validators" do
          context "[:attribute]" do
            it { @book.failed_validators.list.should include(:attribute) }

            context "[:title]" do
              it { @book.failed_validators.list[:attribute].should include(:title) }
            end
          end

          context "[:embedded_model]" do
            it { @book.failed_validators.list.should_not include(:embedded_model) }
          end
        end
      end


      context "and the embedded Model is invalid" do
        before(:all) do
          @book = @book_class.new({
            :title => "Being Batman",
            :Author => {
              :name => ""
            }
          })
        end

        it("returns false") { @book.valid?.should be_false }

        context "failed_validators" do
          context "[:attribute]" do
            it { @book.failed_validators.list.should_not include(:attribute) }
          end

          context "[:embedded_model]" do
            it { @book.failed_validators.list.should include(:embedded_model) }

            context "[:Author]" do
              it { @book.failed_validators.list[:embedded_model].should include(:Author) }

              context "[:attribute]" do
                it { @book.failed_validators.list[:embedded_model][:Author].should include(:attribute) }

                context "[:name]" do
                  it { @book.failed_validators.list[:embedded_model][:Author][:attribute].should include(:name) }
                end
              end
            end
          end
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