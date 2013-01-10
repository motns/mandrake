require 'spec_helper'

describe Mandrake::Model do

  describe "::initialize" do
    before do
      @user = Class.new do
        include Mandrake::Model
        # no default
        key :name, String, :as => :n
        # Proc as default
        key :username, String, :as => :u, \
          default: ->(doc){ return nil if doc.name.nil?; doc.name.gsub(/\s+/, '').downcase }
        # Empty string as default
        key :bio, String, :as => :b, default: ''
        # Integer as default
        key :score, Integer, :as => :s, default: 100
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

end