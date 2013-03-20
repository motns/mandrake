require 'spec_helper'

describe Mandrake::Keys do

  context "::key" do

    context "when called with only the (required) name and type" do
      book_class = Class.new(TestBaseModel) do
        key :title, :String
      end

      it "creates new key in Model" do
        book_class.schema.keys.should include(:title)
      end

      it "creates alias under the same name" do
        book_class.aliases[:title].should eq(:title)
      end

      it "sets the default to nil" do
        book_class.schema[:title][:default].should be_nil
      end

      it "sets the key as not required" do
        book_class.schema[:title][:required].should be_false
      end

      book = book_class.new

      it "creates a getter for key" do
        book.title.should be_nil
      end

      it "creates a setter for key" do
        book.title = "New title"
        book.title.should eq("New title")
      end
    end


    context "when called with extra option" do

      context ":as for setting an alias" do
        book_class = Class.new(TestBaseModel) do
          key :title, :String, :as => :t
        end

        it "creates new key in Model" do
          book_class.schema.keys.should include(:title)
        end

        it "creates the defined alias" do
          book_class.aliases[:t].should eq(:title)
        end

        book = book_class.new

        it "creates a getter for key" do
          book.title.should be_nil
        end

        it "creates a getter for alias" do
          book.t.should be_nil
        end

        it "creates a setter for key" do
          book.title = "New title"
          book.title.should eq("New title")
        end

        it "creates a setter for alias" do
          book.t = "Updated title"
          book.title.should eq("Updated title")
        end
      end


      context ":default" do
        book_class = Class.new(TestBaseModel) do
          key :title, :String, default: "My book"
        end

        it "sets the default value for key" do
          book_class.schema[:title][:default].should eq("My book")
        end
      end


      context ":required => true" do
        book_class = Class.new(TestBaseModel) do
          key :title, :String, required: true
        end

        it "sets the key as required" do
          book_class.schema[:title][:required].should be_true
        end
      end


      context ":length as a Range" do
        book_class = Class.new(TestBaseModel) do
          key :title, :String, length: 2..200
        end

        it "sets the length Range for the key" do
          book_class.schema[:title][:length].should eq(2..200)
        end
      end


      context ":length as an Integer" do
        book_class = Class.new(TestBaseModel) do
          key :title, :String, length: 50
        end

        it "sets the maximum length for the key" do
          book_class.schema[:title][:length].should eq(50)
        end
      end


      context ":format option" do
        book_class = Class.new(TestBaseModel) do
          key :title, :String, format: /\w+/
        end

        it "sets the format requirement on the key" do
          book_class.schema[:title][:format].should eq(/\w+/)
        end
      end
    end


    context "when called with the same name multiple times" do
      it do
        expect {
          Class.new(TestBaseModel) do
            key :title, :String
            key :title, :String
          end
        }.to raise_error(Mandrake::Error::KeyNameError, '"title" is already used as a name or alias for another key')
      end
    end


    context "when called with a name that's already used as an alias" do
      it do
        expect {
          Class.new(TestBaseModel) do
            key :title, :String, as: :t
            key :t, :String
          end
        }.to raise_error(Mandrake::Error::KeyNameError, '"t" is already used as a name or alias for another key')
      end
    end


    context "when called with an alias that's already taken" do
      it do
        expect {
          Class.new(TestBaseModel) do
            key :title, :String, as: :t
            key :theme, :String, as: :t
          end
        }.to raise_error(Mandrake::Error::KeyNameError, '"t" is already used as a name or alias for another key')
      end
    end


    context "when called with an alias that's already used as a field name" do
      it do
        expect {
          Class.new(TestBaseModel) do
            key :title, :String, as: :t
            key :full_title, :String, as: :title
          end
        }.to raise_error(Mandrake::Error::KeyNameError, '"title" is already used as a name or alias for another key')
      end
    end
  end


  context "::schema" do
    context "on a Model with a key (:title)" do
      context "and an embedded Model (:Author)" do
        context "and an embedded Model list (:Pages)" do
          subject do
            author_class = Class.new(TestBaseModel) do
              key :name, :String
            end

            page_class = Class.new(TestBaseModel) do
              key :content, :String
            end

            book_class = Class.new(TestBaseModel) do
              key :title, :String
            end

            book_class.embed_one author_class, :Author
            book_class.embed_many page_class, :Pages
            book_class
          end

          context "::schema" do
            it { subject.schema.should include(:title) }
            it { subject.schema.should include(:Author) }
            it { subject.schema.should include(:Pages) }

            context "[:title]" do
              it { subject.schema[:title].should include(:type) }
              it { subject.schema[:title].should include(:alias) }
              it { subject.schema[:title].should include(:required) }
              it { subject.schema[:title].should include(:default) }
              it { subject.schema[:title].should include(:description) }
            end

            context "[:Author]" do
              it { subject.schema[:Author].should include(:type) }
              it { subject.schema[:Author].should include(:alias) }
              it { subject.schema[:Author].should include(:schema) }

              context "[:type]" do
                it { subject.schema[:Author][:type].should eq(:embedded_model) }
              end

              context "[:schema]" do
                it { subject.schema[:Author][:schema].should include(:name) }

                context "[:name]" do
                  it { subject.schema[:Author][:schema][:name].should include(:type) }
                  it { subject.schema[:Author][:schema][:name].should include(:alias) }
                  it { subject.schema[:Author][:schema][:name].should include(:required) }
                  it { subject.schema[:Author][:schema][:name].should include(:default) }
                  it { subject.schema[:Author][:schema][:name].should include(:description) }
                end
              end
            end

            context "[:Pages]" do
              it { subject.schema[:Pages].should include(:type) }
              it { subject.schema[:Pages].should include(:alias) }
              it { subject.schema[:Pages].should include(:schema) }

              context "[:type]" do
                it { subject.schema[:Pages][:type].should eq(:embedded_model_list) }
              end

              context "[:schema]" do
                it { subject.schema[:Pages][:schema].should include(:content) }

                context "[:name]" do
                  it { subject.schema[:Pages][:schema][:content].should include(:type) }
                  it { subject.schema[:Pages][:schema][:content].should include(:alias) }
                  it { subject.schema[:Pages][:schema][:content].should include(:required) }
                  it { subject.schema[:Pages][:schema][:content].should include(:default) }
                  it { subject.schema[:Pages][:schema][:content].should include(:description) }
                end
              end
            end
          end
        end
      end
    end
  end
end