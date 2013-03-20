require 'spec_helper'

describe Mandrake::Dirty do

  let(:author_class) do
    Class.new(TestBaseModel) do
      key :name, :String
    end
  end

  let(:book_class) do
    klass = Class.new(TestBaseModel) do
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
      subject { book_class.new }
      its(:changed) { should be_empty }
    end

    context 'when :title is updated' do
      subject do
        book = book_class.new
        book.title = 'New Title'
        book
      end

      its(:changed) { should include(:title) }
    end
  end


  context "#changes" do
    context "with a new Model instance" do
      subject { book_class.new }
      its(:changes) { should be_nil }
    end

    context 'when :title is updated from "Old Title" to "New Title"' do
      subject do
        book = book_class.new({:title => "Old Title"})
        book.title = 'New Title'
        book
      end

      context "changes" do
        it { subject.changes.should include(:title) }

        context "[:title]" do
          it { subject.changes[:title].should eq(["Old Title", "New Title"]) }
        end
      end
    end
  end


  context "#attribute_changed?" do
    context "on a Model with a :title key" do
      context "that was just initialized" do
        subject { book_class.new }

        context "when called with :title" do
          it { subject.attribute_changed?(:title).should be_false }

          context "via #title_changed? alias" do
            it { subject.title_changed?.should be_false }
          end
        end
      end

      context "and :title updated" do
        subject do
          book = book_class.new({:title => "Old Title"})
          book.title = 'New Title'
          book
        end

        context "when called with :title" do
          it { subject.attribute_changed?(:title).should be_true }

          context "via #title_changed? alias" do
            it { subject.title_changed?.should be_true }
          end
        end
      end
    end
  end


  context "#attribute_change" do
    context "on a Model with a :title key" do
      context "that was just initialized" do
        subject { book_class.new }

        context "when called with :title" do
          it { subject.attribute_change(:title).should be_nil }

          context "via #title_change alias" do
            it { subject.title_change.should be_nil }
          end
        end
      end

      context 'and :title updated from "Old Title" to "New Title"' do
        subject do
          book = book_class.new({:title => "Old Title"})
          book.title = 'New Title'
          book
        end

        context "when called with :title" do
          it { subject.attribute_change(:title).should eq(["Old Title", "New Title"]) }

          context "via #title_change alias" do
            it { subject.title_change.should eq(["Old Title", "New Title"]) }
          end
        end
      end
    end
  end


  context "#attribute_was" do
    context "on a Model with a :title key" do
      context "that was just initialized" do
        subject { book_class.new }

        context "when called with :title" do
          it { subject.attribute_was(:title).should be_nil }

          context "via #title_change alias" do
            it { subject.title_was.should be_nil }
          end
        end
      end

      context 'and :title updated from "Old Title" to "New Title"' do
        subject do
          book = book_class.new({:title => "Old Title"})
          book.title = 'New Title'
          book
        end

        context "when called with :title" do
          it { subject.attribute_was(:title).should eq("Old Title") }

          context "via #title_was alias" do
            it { subject.title_was.should eq("Old Title") }
          end
        end
      end
    end
  end
end