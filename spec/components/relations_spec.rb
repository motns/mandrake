require 'spec_helper'

describe Mandrake::Relations do
  let(:author) do
    Class.new(TestBaseModel) do
      key :name, :String

      def self.model_name
        ActiveModel::Name.new(self, nil, "Author")
      end
    end
  end


  context "::embed_one" do
    context "when called with only a Model argument (Author)" do
      subject do
        book = Class.new(TestBaseModel)
        book.embed_one author
        book
      end

      context "::relations" do
        it { subject.relations.should include(:embed_one) }

        context "[:embed_one]" do
          it { subject.relations[:embed_one].should include(:Author) }

          context "[:Author]" do
            it { subject.relations[:embed_one][:Author].should include(:model) }
            it { subject.relations[:embed_one][:Author].should include(:alias) }

            context "[:model]" do
              it("should eq Author class") { subject.relations[:embed_one][:Author][:model].should eq(author) }
            end

            context "[:alias]" do
              it { subject.relations[:embed_one][:Author][:alias].should eq(:Author) }
            end
          end
        end
      end
    end


    context "when called with Model (Author) and name (:Maker)" do
      subject do
        book = Class.new(TestBaseModel)
        book.embed_one author, :Maker
        book
      end

      context "::relations" do
        it { subject.relations.should include(:embed_one) }

        context "[:embed_one]" do
          it { subject.relations[:embed_one].should include(:Maker) }

          context "[:Maker]" do
            it { subject.relations[:embed_one][:Maker].should include(:model) }
            it { subject.relations[:embed_one][:Maker].should include(:alias) }

            context "[:model]" do
              it("should eq Author class") { subject.relations[:embed_one][:Maker][:model].should eq(author) }
            end

            context "[:alias]" do
              it { subject.relations[:embed_one][:Maker][:alias].should eq(:Maker) }
            end
          end
        end
      end
    end


    context "when called with Model (Author), name (:Maker) and alias (:m)" do
      subject do
        book = Class.new(TestBaseModel)
        book.embed_one author, :Maker, as: :m
        book
      end

      context "::relations" do
        it { subject.relations.should include(:embed_one) }

        context "[:embed_one]" do
          it { subject.relations[:embed_one].should include(:Maker) }

          context "[:Maker]" do
            it { subject.relations[:embed_one][:Maker].should include(:model) }
            it { subject.relations[:embed_one][:Maker].should include(:alias) }

            context "[:model]" do
              it("should eq Author class") { subject.relations[:embed_one][:Maker][:model].should eq(author) }
            end

            context "[:alias]" do
              it { subject.relations[:embed_one][:Maker][:alias].should eq(:m) }
            end
          end
        end
      end
    end


    context "when called with Model (Author), name (:Maker) and alias (:m)" do
      context "and again with Model (Author), name (:Creator) and alias (:c)" do
        subject do
          book = Class.new(TestBaseModel)
          book.embed_one author, :Maker, as: :m
          book.embed_one author, :Creator, as: :c
          book
        end

        context "::relations" do
          it { subject.relations.should include(:embed_one) }

          context "[:embed_one]" do
            it { subject.relations[:embed_one].should include(:Maker) }
            it { subject.relations[:embed_one].should include(:Creator) }

            context "[:Maker]" do
              it { subject.relations[:embed_one][:Maker].should include(:model) }
              it { subject.relations[:embed_one][:Maker].should include(:alias) }

              context "[:model]" do
                it("should eq Author class") { subject.relations[:embed_one][:Maker][:model].should eq(author) }
              end

              context "[:alias]" do
                it { subject.relations[:embed_one][:Maker][:alias].should eq(:m) }
              end
            end

            context "[:Creator]" do
              it { subject.relations[:embed_one][:Creator].should include(:model) }
              it { subject.relations[:embed_one][:Creator].should include(:alias) }

              context "[:model]" do
                it("should eq Author class") { subject.relations[:embed_one][:Creator][:model].should eq(author) }
              end

              context "[:alias]" do
                it { subject.relations[:embed_one][:Creator][:alias].should eq(:c) }
              end
            end
          end
        end
      end
    end


    context "when called with a non-Model argument (String)" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_one String
        }.to raise_error(Mandrake::Error::EmbedError, 'model has to be a Mandrake::Model class, String given')
      end
    end


    context "when called with the same Model (Author), and no arguments twice" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_one author
          book.embed_one author
        }.to raise_error(Mandrake::Error::KeyNameError, '"Author" is already used as a name or alias for another key')
      end
    end


    context "when called with the same Model (Author), and the same name twice" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_one author, :Creator
          book.embed_one author, :Creator
        }.to raise_error(Mandrake::Error::KeyNameError, '"Creator" is already used as a name or alias for another key')
      end
    end


    context "when called with the same Model (Author), and the same alias twice" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_one author, :Maker, as: :a
          book.embed_one author, :Creator, as: :a
        }.to raise_error(Mandrake::Error::KeyNameError, '"a" is already used as a name or alias for another key')
      end
    end
  end


  context "::embed_many" do
    context "when called with only a Model argument (Author)" do
      subject do
        book = Class.new(TestBaseModel)
        book.embed_many author
        book
      end

      context "::relations" do
        it { subject.relations.should include(:embed_many) }

        context "[:embed_many]" do
          it { subject.relations[:embed_many].should include(:Authors) }

          context "[:Authors]" do
            it { subject.relations[:embed_many][:Authors].should include(:model) }
            it { subject.relations[:embed_many][:Authors].should include(:alias) }

            context "[:model]" do
              it("should eq Author class") { subject.relations[:embed_many][:Authors][:model].should eq(author) }
            end

            context "[:alias]" do
              it { subject.relations[:embed_many][:Authors][:alias].should eq(:Authors) }
            end
          end
        end
      end
    end


    context "when called with Model (Author) and name (:Makers)" do
      subject do
        book = Class.new(TestBaseModel)
        book.embed_many author, :Makers
        book
      end

      context "::relations" do
        it { subject.relations.should include(:embed_many) }

        context "[:embed_many]" do
          it { subject.relations[:embed_many].should include(:Makers) }

          context "[:Makers]" do
            it { subject.relations[:embed_many][:Makers].should include(:model) }
            it { subject.relations[:embed_many][:Makers].should include(:alias) }

            context "[:model]" do
              it("should eq Author class") { subject.relations[:embed_many][:Makers][:model].should eq(author) }
            end

            context "[:alias]" do
              it { subject.relations[:embed_many][:Makers][:alias].should eq(:Makers) }
            end
          end
        end
      end
    end


    context "when called with Model (Author), name (:Makers) and alias (:ms)" do
      subject do
        book = Class.new(TestBaseModel)
        book.embed_many author, :Makers, as: :ms
        book
      end

      context "::relations" do
        it { subject.relations.should include(:embed_many) }

        context "[:embed_many]" do
          it { subject.relations[:embed_many].should include(:Makers) }

          context "[:Makers]" do
            it { subject.relations[:embed_many][:Makers].should include(:model) }
            it { subject.relations[:embed_many][:Makers].should include(:alias) }

            context "[:model]" do
              it("should eq Author class") { subject.relations[:embed_many][:Makers][:model].should eq(author) }
            end

            context "[:alias]" do
              it { subject.relations[:embed_many][:Makers][:alias].should eq(:ms) }
            end
          end
        end
      end
    end


    context "when called with Model (Author), name (:Makers) and alias (:ms)" do
      context "and again with Model (Author), name (:Creators) and alias (:cs)" do
        subject do
          book = Class.new(TestBaseModel)
          book.embed_many author, :Makers, as: :ms
          book.embed_many author, :Creators, as: :cs
          book
        end

        context "::relations" do
          it { subject.relations.should include(:embed_many) }

          context "[:embed_many]" do
            it { subject.relations[:embed_many].should include(:Makers) }
            it { subject.relations[:embed_many].should include(:Creators) }

            context "[:Makers]" do
              it { subject.relations[:embed_many][:Makers].should include(:model) }
              it { subject.relations[:embed_many][:Makers].should include(:alias) }

              context "[:model]" do
                it("should eq Author class") { subject.relations[:embed_many][:Makers][:model].should eq(author) }
              end

              context "[:alias]" do
                it { subject.relations[:embed_many][:Makers][:alias].should eq(:ms) }
              end
            end

            context "[:Creators]" do
              it { subject.relations[:embed_many][:Creators].should include(:model) }
              it { subject.relations[:embed_many][:Creators].should include(:alias) }

              context "[:model]" do
                it("should eq Author class") { subject.relations[:embed_many][:Creators][:model].should eq(author) }
              end

              context "[:alias]" do
                it { subject.relations[:embed_many][:Creators][:alias].should eq(:cs) }
              end
            end
          end
        end
      end
    end


    context "when called with a non-Model argument (String)" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_many String
        }.to raise_error(Mandrake::Error::EmbedError, 'model has to be a Mandrake::Model class, String given')
      end
    end


    context "when called with the same Model (Author), and no arguments twice" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_many author
          book.embed_many author
        }.to raise_error(Mandrake::Error::KeyNameError, '"Authors" is already used as a name or alias for another key')
      end
    end


    context "when called with the same Model (Author), and the same name twice" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_many author, :Creators
          book.embed_many author, :Creators
        }.to raise_error(Mandrake::Error::KeyNameError, '"Creators" is already used as a name or alias for another key')
      end
    end


    context "when called with the same Model (Author), and the same alias twice" do
      it do
        expect {
          book = Class.new(TestBaseModel)
          book.embed_many author, :Makers, as: :as
          book.embed_many author, :Creators, as: :as
        }.to raise_error(Mandrake::Error::KeyNameError, '"as" is already used as a name or alias for another key')
      end
    end
  end
end