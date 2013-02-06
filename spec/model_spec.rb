require 'spec_helper'

describe Mandrake::Model do

  describe "::initialize" do
    before do
      @user = Class.new(TestBaseModel) do
        # no default
        key :name, :String, :as => :n
        # Proc as default
        key :username, :String, :as => :u, \
          default: ->(doc){ return nil if doc.name.nil?; doc.name.gsub(/\s+/, '').downcase }
        # Empty string as default
        key :bio, :String, :as => :b, default: ''
        # Integer as default
        key :score, :Integer, :as => :s, default: 100
      end
    end


    context "with an empty hash" do
      before do
        @doc = @user.new
      end

      it "sets keys with no defaults to nil" do
        @doc.name.should be_nil
      end

      it "sets keys with Proc defaults to the return values" do
        @doc.username.should be_nil
      end

      it "sets keys with scalar defaults to the given values" do
        @doc.bio.should eq('')
        @doc.score.should eq(100)
      end

      it "identifies all keys as new" do
        @doc.new_keys.should include(:name, :username, :bio, :score)
      end

      it "identifies no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting some of the values" do
      before do
        @doc = @user.new({
          n: "Bruce Wayne",
          b: "I'm the Batman, baby!"
        })
      end

      it "sets keys with Proc defaults to the return values" do
        @doc.username.should eq('brucewayne')
      end

      it "sets keys with scalar defaults to the given values" do
        @doc.score.should eq(100)
      end

      it "sets the defined keys to the given values" do
        @doc.name.should eq('Bruce Wayne')
        @doc.bio.should eq("I'm the Batman, baby!")
      end

      it "identifies the missing keys as new" do
        @doc.new_keys.should include(:username, :score)
      end

      it "identifies no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting all of the values by their alias" do
      before do
        @doc = @user.new({
          n: "Bruce Wayne",
          u: "batman",
          b: "I'm the Batman, baby!",
          s: 300
        })
      end

      it "sets the defined keys to the given values" do
        @doc.name.should eq('Bruce Wayne')
        @doc.username.should eq('batman')
        @doc.bio.should eq("I'm the Batman, baby!")
        @doc.score.should eq(300)
      end

      it "identifies no keys as new" do
        @doc.new_keys.should be_empty
      end

      it "identifies no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting all of the values by their key name" do
      before do
        @doc = @user.new({
          name: "Bruce Wayne",
          username: "batman",
          bio: "I'm the Batman, baby!",
          score: 300
        })
      end

      it "sets the defined keys to the given values" do
        @doc.name.should eq('Bruce Wayne')
        @doc.username.should eq('batman')
        @doc.bio.should eq("I'm the Batman, baby!")
        @doc.score.should eq(300)
      end

      it "identifies all keys as new" do
        @doc.new_keys.should include(:name, :username, :bio, :score)
      end

      it "identifies no keys as removed" do
        @doc.removed_keys.should be_empty
      end
    end


    context "with a hash setting all of the values by both their key name and alias" do
      before do
        @doc = @user.new({
          n: "Bruce Wayne",
          name: "Bruce Wayne2",
          u: "batman",
          username: "batman2",
          b: "I'm the Batman, baby!",
          bio: "I'm Robin, baby!",
          s: 300,
          score: 200
        })
      end

      it "sets the defined keys to the given values" do
        @doc.name.should eq('Bruce Wayne')
        @doc.username.should eq('batman')
        @doc.bio.should eq("I'm the Batman, baby!")
        @doc.score.should eq(300)
      end

      it "identifies no keys as new" do
        @doc.new_keys.should be_empty
      end

      it "identifies the full key names as removed" do
        @doc.removed_keys.should include(:name, :username, :bio, :score)
      end
    end


    context "with a hash containing additional values" do
      before do
        @doc = @user.new({
          n: "Bruce Wayne",
          u: "batman",
          b: "I'm the Batman, baby!",
          s: 300,
          c: "Batmobil",
          p: "Robin"
        })
      end

      it "sets the defined keys to the given values" do
        @doc.name.should eq('Bruce Wayne')
        @doc.username.should eq('batman')
        @doc.bio.should eq("I'm the Batman, baby!")
        @doc.score.should eq(300)
      end

      it "identifies no keys as new" do
        @doc.new_keys.should be_empty
      end

      it "identifies additional keys as removed" do
        @doc.removed_keys.should include(:c, :p)
      end
    end
  end

  describe "#read_attribute" do
    before do
      user_class = Class.new(TestBaseModel) do
        key :name, :String, :as => :n
      end

      @user = user_class.new({name: "John Smith"})
    end

    it "returns the attribute value" do
      @user.read_attribute(:name).should eq("John Smith")
    end
  end


  describe "#write_attribute" do
    before(:all) do
      user_class = Class.new(TestBaseModel) do
        key :name, :String, :as => :n
      end

      @user = user_class.new({name: "John Smith"})

      @user.send :write_attribute, :name, "Peter Parker"
    end

    it "updates the attribute value" do
      @user.read_attribute(:name).should eq("Peter Parker")
    end
  end


  describe "#increment_attribute" do
    before(:all) do
      @user_class = Class.new(TestBaseModel) do
        key :age, :Integer, :as => :a
        key :name, :String, :as => :n
      end
    end

    context "on Numeric key" do
      context "with no arguments" do
        before(:all) do
          @user = @user_class.new({age: 25})
          @user.send :increment_attribute, :age
        end

        it "increments the attribute value by 1" do
          @user.read_attribute(:age).should eq(26)
        end

        it "shows that the value was incremented by 1" do
          @user.attribute_incremented_by(:age).should eq(1)
        end
      end


      context "with positive argument" do
        before(:all) do
          @user = @user_class.new({age: 25})
          @user.send :increment_attribute, :age, 5
        end

        it "increments the attribute value by given amount" do
          @user.read_attribute(:age).should eq(30)
        end

        it "shows that the value was incremented by given amount" do
          @user.attribute_incremented_by(:age).should eq(5)
        end
      end


      context "with negative argument" do
        before(:all) do
          @user = @user_class.new({age: 25})
          @user.send :increment_attribute, :age, -4
        end

        it "decrements the attribute value by given amount" do
          @user.read_attribute(:age).should eq(21)
        end

        it "shows that the value was decremented by given amount" do
          @user.attribute_incremented_by(:age).should eq(-4)
        end
      end


      context "with non-Numeric argument" do
        before(:all) do
          @user = @user_class.new({age: 25})
        end

        it "raises an error" do
          expect {
            @user.send :increment_attribute, :age, 2.3
          }.to raise_error('The increment has to be an Integer, Float given')
        end
      end
    end

    context "on non-Numeric key" do
      before(:all) do
        @user = @user_class.new({age: 25, name: "Peter Parker"})
      end

      it "raises an error" do
        expect {
          @user.send :increment_attribute, :name
        }.to raise_error("Type String doesn't support incrementing")
      end
    end
  end


  describe "#attribute_incremented_by" do
    before(:all) do
      @user_class = Class.new(TestBaseModel) do
        key :age, :Integer, :as => :a
        key :name, :String, :as => :n
      end
    end

    context "on Numeric key" do
      context "with initial value" do
        before(:all) do
          @user = @user_class.new({age: 25})
        end

        it "returns 0" do
          @user.attribute_incremented_by(:age).should eq(0)
        end
      end

      context "with incremented value" do
        before(:all) do
          @user = @user_class.new({age: 25})
          @user.send :increment_attribute, :age, 5
        end

        it "returns the increment" do
          @user.attribute_incremented_by(:age).should eq(5)
        end
      end
    end

    context "on non-Numeric key" do
      before(:all) do
        @user = @user_class.new({age: 25})
      end

      it "raises an error" do
        expect {
          @user.attribute_incremented_by(:name)
        }.to raise_error("Type String doesn't support incrementing")
      end
    end
  end
end