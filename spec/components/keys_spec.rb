require 'spec_helper'

describe Mandrake::Keys do

  context "with a valid definition" do
    let(:book) do
      Class.new {
        include Mandrake::Document
        key :title, String
        key :pages, Integer
      }
    end

    it "returns the current keys" do
      book.keys.should eq({
        :title => {
          :type => String,
          :alias => :title
        },
        :pages => {
          :type => Integer,
          :alias => :pages
        }
      })
    end
  end

  context "with an invalid definition" do

    it "throws an exception on a duplicate key name" do
      expect {
        class Book
          include Mandrake::Document

          key :title, String
          key :title, String
        end
      }.to raise_error('Key "title" is already defined')
    end

  end

end