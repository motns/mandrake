require 'spec_helper'

describe Mandrake::Dirty do

  let(:author_class) do
    Class.new(TestBaseModel) do
      key :name, :String
    end
  end

  let(:book_class) do
    klass = Class.new(TestBaseDoc) do
      key :title, :String, :as => :t
    end
    klass.embed_one author_class, :Author
    klass
  end


  context "#changed?" do
    context "with a new Model instance" do
      subject do
        book_class.new({
          :title => "Old title",
          :Author => {
            :name => "Bruce Wayne"
          }
        })
      end

      its(:changed?) { should be_false }
    end

    context "with an attribute that's updated" do
      subject do
        book = book_class.new({
          :title => "Old title",
          :Author => {
            :name => "Bruce Wayne"
          }
        })

        book.title = "New Title"
        book
      end

      its(:changed?) { should be_true }
    end

    context "with an embedded Model that's updated" do
      subject do
        book = book_class.new({
          :title => "Old title",
          :Author => {
            :name => "Bruce Wayne"
          }
        })

        book.Author.name = "Peter Parker"
        book
      end

      its(:changed?) { should be_true }
    end
  end


  context "#changed" do
    context "with a new Model instance" do
      subject { author_class.new }
      its(:changed) { should be_empty }
    end

    context 'when :name is updated' do
      subject do
        author = author_class.new
        author.name = 'New Name'
        author
      end

      its(:changed) { should include(:name) }
    end
  end


  context "#changes" do
    context "with a new Model instance" do
      subject { author_class.new }
      its(:changes) { should be_nil }
    end

    context 'when :name is updated from "Old Name" to "New Name"' do
      subject do
        author = author_class.new({:name => "Old Name"})
        author.name = 'New Name'
        author
      end

      context "changes" do
        it { subject.changes.should include(:name) }

        context "[:name]" do
          it { subject.changes[:name].should eq(["Old Name", "New Name"]) }
        end
      end
    end
  end


  context "#attribute_changed?" do
    context "on a Model with a :name key" do
      context "that was just initialized" do
        subject { author_class.new }

        context "when called with :name" do
          it { subject.attribute_changed?(:name).should be_false }

          context "via #name_changed? alias" do
            it { subject.name_changed?.should be_false }
          end
        end
      end

      context "and :name updated" do
        subject do
          author = author_class.new({:name => "Old Name"})
          author.name = 'New Name'
          author
        end

        context "when called with :name" do
          it { subject.attribute_changed?(:name).should be_true }

          context "via #name_changed? alias" do
            it { subject.name_changed?.should be_true }
          end
        end
      end
    end
  end


  context "#attribute_change" do
    context "on a Model with a :name key" do
      context "that was just initialized" do
        subject { author_class.new }

        context "when called with :name" do
          it { subject.attribute_change(:name).should be_nil }

          context "via #name_change alias" do
            it { subject.name_change.should be_nil }
          end
        end
      end

      context 'and :name updated from "Old Name" to "New Name"' do
        subject do
          author = author_class.new({:name => "Old Name"})
          author.name = 'New Name'
          author
        end

        context "when called with :name" do
          it { subject.attribute_change(:name).should eq(["Old Name", "New Name"]) }

          context "via #name_change alias" do
            it { subject.name_change.should eq(["Old Name", "New Name"]) }
          end
        end
      end
    end
  end


  context "#attribute_was" do
    context "on a Model with a :name key" do
      context "that was just initialized" do
        subject { author_class.new }

        context "when called with :name" do
          it { subject.attribute_was(:name).should be_nil }

          context "via #name_change alias" do
            it { subject.name_was.should be_nil }
          end
        end
      end

      context 'and :name updated from "Old Name" to "New Name"' do
        subject do
          author = author_class.new({:name => "Old Name"})
          author.name = 'New Name'
          author
        end

        context "when called with :name" do
          it { subject.attribute_was(:name).should eq("Old Name") }

          context "via #name_was alias" do
            it { subject.name_was.should eq("Old Name") }
          end
        end
      end
    end
  end
end