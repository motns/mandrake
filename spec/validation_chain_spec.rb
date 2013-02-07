require 'spec_helper'

describe Mandrake::ValidationChain do
  context "#add" do
    context "when called with a Validation" do
      before(:all) do
        @chain = described_class.new
        @validation = Mandrake::Validation.new(:Presence, :title)
        @chain.add(@validation)
      end

      it "adds item to chain" do
        @chain.items.should include(@validation)
      end
    end


    context "when called with a ValidationChain" do
      before(:all) do
        @chain = described_class.new
        @chain2 = described_class.new
        @chain.add(@chain2)
      end

      it "adds item to chain" do
        @chain.items.should include(@chain2)
      end
    end


    context "when called with item that's not Validation or ValidationChain" do
      it "raises error" do
        expect {
          described_class.new.add("stuff")
        }.to raise_error("Validator chain item has to be a Validator or another ValidationChain")
      end
    end
  end


  context "#run" do
    before(:all) do
      @user = Class.new(TestBaseModel) do
        key :username, :String
        key :name, :String
      end

      @validation1 = Mandrake::Validation.new(:Presence, :username)
      @validation2 = Mandrake::Validation.new(:Format, :username, format: :alnum)
      @validation3 = Mandrake::Validation.new(:Presence, :name)
    end


    context "with a single Validation in the chain" do
      before(:all) do
        @chain = Mandrake::ValidationChain.new
        @chain.add(@validation1)
      end

      context "and a valid document being passed in" do
        before(:all) do
          @doc = @user.new({:username => "batman1"})
        end

        it "returns true" do
          @chain.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and an invalid document being passed in" do
        before(:all) do
          @doc = @user.new
        end

        it "returns false" do
          @chain.run(@doc).should be_false
        end

        it "adds the failed validator for attribute" do
          @doc.failed_validators.list.should include(:username)
          @doc.failed_validators.list[:username].should include({
            :validator => :Presence,
            :error_code => :missing,
            :message => "must be provided"
          })
        end
      end
    end


    context "with multiple Validations in the chain" do
      context "and :stop_on_failure set to true" do
        before(:all) do
          @chain = Mandrake::ValidationChain.new
          @chain.add(@validation1, @validation2)
        end

        context "and a valid document being passed in" do
          before(:all) do
            @doc = @user.new({:username => "batman1"})
          end

          it "returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators" do
            @doc.failed_validators.list.should be_empty
          end
        end

        context "and an invalid document being passed in" do
          before(:all) do
            @doc = @user.new
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds only first failed validator" do
            @doc.failed_validators.list.should include(:username)
            @doc.failed_validators.list[:username].length.should eq(1)
            @doc.failed_validators.list[:username].should include({
              :validator => :Presence,
              :error_code => :missing,
              :message => "must be provided"
            })
          end
        end
      end


      context "and :stop_on_failure set to false" do
        before(:all) do
          @chain = Mandrake::ValidationChain.new(false)
          @chain.add(@validation1, @validation2)
        end

        context "and an invalid document being passed in" do
          before(:all) do
            @doc = @user.new(username: "")
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds all failed validators" do
            @doc.failed_validators.list.should include(:username)

            @doc.failed_validators.list[:username].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })

            @doc.failed_validators.list[:username].should include({
              :validator => :Format,
              :error_code => :not_alnum,
              :message => "can only contain letters and numbers"
            })
          end
        end
      end
    end


    context "with a Validation and another ValidationChain in the chain" do
      before(:all) do
        @chain2 = Mandrake::ValidationChain.new
        @chain2.add(@validation3)
      end

      context "and :stop_on_failure set to true" do
        before(:all) do
          @chain = Mandrake::ValidationChain.new
          @chain.add(@validation1, @chain2)
        end

        context "and a valid document being passed in" do
          before(:all) do
            @doc = @user.new({:username => "batman1", :name => "Bruce Wayne"})
          end

          it "returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators" do
            @doc.failed_validators.list.should be_empty
          end
        end

        context "and an invalid document being passed in" do
          before(:all) do
            @doc = @user.new
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds only first failed validator" do
            @doc.failed_validators.list.should include(:username)
            @doc.failed_validators.list[:username].length.should eq(1)
            @doc.failed_validators.list[:username].should include({
              :validator => :Presence,
              :error_code => :missing,
              :message => "must be provided"
            })
          end
        end
      end


      context "and :stop_on_failure set to false" do
        before(:all) do
          @chain = Mandrake::ValidationChain.new(false)
          @chain.add(@validation1, @chain2)
        end

        context "and an invalid document being passed in" do
          before(:all) do
            @doc = @user.new
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds all failed validators" do
            @doc.failed_validators.list.should include(:username)
            @doc.failed_validators.list.should include(:name)

            @doc.failed_validators.list[:username].should include({
              :validator => :Presence,
              :error_code => :missing,
              :message => "must be provided"
            })

            @doc.failed_validators.list[:name].should include({
              :validator => :Presence,
              :error_code => :missing,
              :message => "must be provided"
            })
          end
        end
      end
    end
  end
end