require 'spec_helper'

describe Mandrake::Document do

  context "with a valid definition" do
    before do
      @doc = Class.new {
        include Mandrake::Document

        key :title, String
      }
    end

    it "return the current keys" do
      @doc.keys.should eq({
        :title => {
          :type => String,
          :alias => :title
        }
      })
    end
  end

  context "with an invalid definition" do

    it "throw an exception on a duplicate key name" do
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