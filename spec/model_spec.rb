require 'spec_helper'

describe Mandrake::Model do

  describe "::initialize" do
    context "on a Model with a single key (:name) defined" do
      context "that has no alias" do
        context "and no default" do
          before(:all) do
            @user_class = Class.new(TestBaseModel) do
              key :name, :String
            end
          end

          context "when called with {}" do
            subject { @user_class.new({}) }
            its(:name) { should be_nil }
            its(:force_save_keys) { should include(:name) }
          end

          context "when called with {:name => 'batman'}" do
            subject { @user_class.new({:name => 'batman'}) }
            its(:name) { should eq("batman") }
            its(:force_save_keys) { should be_empty }
          end
        end


        context "and the scalar default 'robin'" do
          before(:all) do
            @user_class = Class.new(TestBaseModel) do
              key :name, :String, default: "robin"
            end
          end

          context "when called with {}" do
            subject { @user_class.new({}) }
            its(:name) { should eq("robin") }
            its(:force_save_keys) { should include(:name) }
          end

          context "when called with {:name => 'batman'}" do
            subject { @user_class.new({:name => 'batman'}) }
            its(:name) { should eq("batman") }
            its(:force_save_keys) { should be_empty }
          end
        end


        context "and a Proc { 3 + 3 } default" do
          before(:all) do
            @user_class = Class.new(TestBaseModel) do
              key :name, :String, default: ->(doc){ 3 + 3 }
            end
          end

          context "when called with {}" do
            subject { @user_class.new({}) }
            its(:name) { should eq("6") }
            its(:force_save_keys) { should include(:name) }
          end

          context "when called with {:name => 'batman'}" do
            subject { @user_class.new({:name => 'batman'}) }
            its(:name) { should eq("batman") }
            its(:force_save_keys) { should be_empty }
          end

          context "when called with {:name => 'batman', :age => 30}" do
            subject { @user_class.new({:name => 'batman', :age => 30}) }
            its(:name) { should eq("batman") }
            its(:force_save_keys) { should be_empty }
          end
        end
      end


      context "that has the alias :n" do
        before(:all) do
          @user_class = Class.new(TestBaseModel) do
            key :name, :String, :as => :n
          end
        end

        context "when called with {}" do
          subject { @user_class.new({}) }
          its(:name) { should be_nil }
          its(:force_save_keys) { should include(:name) }
        end

        context "when called with {:n => 'batman'}" do
          subject { @user_class.new({:n => 'batman'}) }
          its(:name) { should eq("batman") }
          its(:force_save_keys) { should be_empty }
        end

        context "when called with {:n => 'batman', :name => 'robin'}" do
          subject { @user_class.new({:n => 'batman', :name => 'robin'}) }
          its(:name) { should eq("batman") }
          its(:force_save_keys) { should be_empty }
        end
      end
    end

    context "on a Model with multiple keys (:name, :age) defined" do
      before(:all) do
        @user_class = Class.new(TestBaseModel) do
          key :name, :String
          key :age, :Integer
        end
      end

      context "when called with {}" do
        subject { @user_class.new({}) }
        its(:name) { should be_nil }
        its(:age) { should be_nil }
        its(:force_save_keys) { should include(:name) }
        its(:force_save_keys) { should include(:age) }
      end

      context "when called with {:age => 25}" do
        subject { @user_class.new({:age => 25}) }
        its(:name) { should be_nil }
        its(:age) { should eq(25) }
        its(:force_save_keys) { should include(:name) }
      end

      context "when called with {:name => 'batman', :age => 25}" do
        subject { @user_class.new({:name => "batman", :age => 25}) }
        its(:name) { should eq("batman") }
        its(:age) { should eq(25) }
        its(:force_save_keys) { should be_empty }
      end
    end
  end


  context "#read_attribute" do
    context 'on a Model with a single key (:name => "John Smith")' do
      subject do
        Class.new(TestBaseModel){
          key :name, :String, :as => :n
        }.new({name: "John Smith"})
      end

      context "when called with :name" do
        it('returns "John Smith"'){ subject.read_attribute(:name).should eq("John Smith") }
      end
    end
  end


  context "#write_attribute" do
    context 'on a Model with a single key (:name => "John Smith")' do
      subject do
        Class.new(TestBaseModel){
          key :name, :String, :as => :n
        }.new({name: "John Smith"})
      end

      context 'when called with :name, "Peter Parker"' do
        before(:all) { subject.write_attribute(:name, "Peter Parker") }
        its(:name) { should eq("Peter Parker") }

        context "attribute_changed_by(:name)" do
          it { subject.attribute_changed_by(:name).should eq(:setter) }
        end
      end
    end
  end


  context "#increment_attribute" do
    context 'on a Model with a Numeric key (:age => 25)' do
      subject do
        Class.new(TestBaseModel){
          key :age, :Integer
        }.new({age: 25})
      end

      context "when called with :age, nil" do
        before(:all) { subject.increment_attribute(:age) }
        its(:age) { should eq(26) }

        context "attribute_incremented_by(:age)" do
          it { subject.attribute_incremented_by(:age).should eq(1) }
        end

        context "attribute_changed_by(:age)" do
          it { subject.attribute_changed_by(:age).should eq(:modifier) }
        end
      end


      context "when called with :age, 3" do
        before(:all) { subject.increment_attribute(:age, 3) }
        its(:age) { should eq(28) }

        context "attribute_incremented_by(:age)" do
          it { subject.attribute_incremented_by(:age).should eq(3) }
        end

        context "attribute_changed_by(:age)" do
          it { subject.attribute_changed_by(:age).should eq(:modifier) }
        end
      end


      context "when called with :age, -4" do
        before(:all) { subject.increment_attribute(:age, -4) }
        its(:age) { should eq(21) }

        context "attribute_incremented_by(:age)" do
          it { subject.attribute_incremented_by(:age).should eq(-4) }
        end

        context "attribute_changed_by(:age)" do
          it { subject.attribute_changed_by(:age).should eq(:modifier) }
        end
      end


      context "when called with :age, 2.3" do
        it do
          expect {
            subject.increment_attribute(:age, 2.3)
          }.to raise_error('The increment has to be an Integer, Float given')
        end
      end
    end

    context 'on a Model with a non-Numeric key (:name => "Bruce Wayne")' do
      subject do
        Class.new(TestBaseModel){
          key :name, :String
        }.new({name: "Bruce Wayne"})
      end

      it do
        expect {
          subject.increment_attribute(:name)
        }.to raise_error("Type String doesn't support increment")
      end
    end
  end


  context "#attribute_incremented_by" do
    context 'on a Model with a single key (:name => "Bruce Wayne")' do
      subject do
        Class.new(TestBaseModel){
          key :name, :String
        }.new({name: "Bruce Wayne"})
      end

      it do
        expect {
          subject.attribute_incremented_by(:name)
        }.to raise_error("Type String doesn't support incremented_by")
      end
    end
  end


  context "#push_to_attribute" do
    context 'on a Model with a Collection key (:tags => [])' do
      subject do
        Class.new(TestBaseModel){
          key :tags, :Array
        }.new
      end

      context 'when called with "batman"' do
        before { subject.push_to_attribute(:tags, "batman") }
        its(:tags) { should include("batman") }
      end

      context 'when called with "robin" via #push alias' do
        before { subject.push(:tags, "robin") }
        its(:tags) { should include("robin") }
      end
    end


    context 'on a Model with a non-Collection key (:name => "")' do
      subject do
        Class.new(TestBaseModel){
          key :name, :String
        }.new
      end

      it do
        expect {
          subject.push_to_attribute(:name, "batman")
        }.to raise_error("Type String doesn't support push")
      end
    end
  end


  context "#pull_from_attribute" do
    context 'on a Model with a Collection key (:tags => ["batman", "robin"])' do
      subject do
        Class.new(TestBaseModel){
          key :tags, :Array
        }.new(tags: ["batman", "robin"])
      end

      context 'when called with "batman"' do
        before { subject.pull_from_attribute(:tags, "batman") }
        its(:tags) { should_not include("batman") }
      end

      context 'when called with "robin" via #pull alias' do
        before { subject.pull(:tags, "robin") }
        its(:tags) { should_not include("robin") }
      end
    end


    context 'on a Model with a non-Collection key (:name => "")' do
      subject do
        Class.new(TestBaseModel){
          key :name, :String
        }.new
      end

      it do
        expect {
          subject.pull_from_attribute(:name, "batman")
        }.to raise_error("Type String doesn't support pull")
      end
    end
  end
end