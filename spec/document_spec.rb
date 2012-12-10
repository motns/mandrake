require 'spec_helper'

describe Mandrake::Document do

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

end