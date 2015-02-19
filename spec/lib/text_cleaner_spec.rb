require 'spec_helper'
require 'text_cleaner'

describe TextCleaner do

  describe ".clean" do
    it "should return nil if nil is given" do
      expect(TextCleaner.clean(nil)).to be_nil
    end
    it "should convert line breaks to unix LF" do
      expect(TextCleaner.clean("\ra\r\nb\r\r\nc\n")).to eq "\na\nb\n\nc\n"
    end
    it "should remove trailing whitespace from lines" do
      expect(TextCleaner.clean("a \nb\t\nc \t \t\n\t ")).to eq "a\nb\nc\n"
    end
    it "should remove leading whitespace from lines" do
      expect(TextCleaner.clean(" a\n\tb\n \t \tc\n\t ")).to eq "a\nb\nc\n"
    end
    it "should remove whitespace runs" do
      expect(TextCleaner.clean("a  b\t\tc \t \td")).to eq "a b\tc d"
    end
    it "should remove excess linebreaks" do
      expect(TextCleaner.clean("\na\n\nb\n\n\nc\n\n\n\n")).to eq "\na\n\nb\n\nc\n\n"
    end
    it "should cleanup everything at once" do
      expect(TextCleaner.clean("\r a \r\r\tb\t\r\r\r \tc \td\t \t \r \r\t\r  \r\t\t")).to eq "\na\n\nb\n\nc d\n\n"
    end
  end

end
