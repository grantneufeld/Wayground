require 'spec_helper'
require 'text_cleaner'

describe TextCleaner do

  describe ".clean" do
    it "should return nil if nil is given" do
      TextCleaner.clean(nil).should be_nil
    end
    it "should convert line breaks to unix LF" do
      TextCleaner.clean("\ra\r\nb\r\r\nc\n").should eq "\na\nb\n\nc\n"
    end
    it "should remove trailing whitespace from lines" do
      TextCleaner.clean("a \nb\t\nc \t \t\n\t ").should eq "a\nb\nc\n"
    end
    it "should remove leading whitespace from lines" do
      TextCleaner.clean(" a\n\tb\n \t \tc\n\t ").should eq "a\nb\nc\n"
    end
    it "should remove whitespace runs" do
      TextCleaner.clean("a  b\t\tc \t \td").should eq "a b\tc d"
    end
    it "should remove excess linebreaks" do
      TextCleaner.clean("\na\n\nb\n\n\nc\n\n\n\n").should eq "\na\n\nb\n\nc\n\n"
    end
    it "should cleanup everything at once" do
      TextCleaner.clean("\r a \r\r\tb\t\r\r\r \tc \td\t \t \r \r\t\r  \r\t\t").should eq "\na\n\nb\n\nc d\n\n"
    end
  end

end
