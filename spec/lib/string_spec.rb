require 'spec_helper'

describe String do
  # Test the string folding addition to the `String` class.
  describe "fold!" do
    it "should default to 75 characters as the fold length" do
      expect(("a" * (75 * 3)).fold!).to eq [("a" * 75),("a" * 74),("a" * 74),"aa"].join("\r\n ")
    end
    it "should do nothing to a string that is equal to the fold length" do
      expect(("a" * 10).fold!(10)).to eq("a" * 10)
    end
    it "should fold a string that is 1 character longer than the fold length" do
      expect(("a" * 13).fold!(12)).to eq(("a" * 12) + "\r\n a")
    end
    it "should use the firstline pre count to determine the fold" do
      expect(("123456789" * 5).fold!(10,5)).to eq("12345\r\n " + ("678912345\r\n " * 4) + "6789")
    end
    it "should default to CRLFspace as the fold sequence" do
      expect(("a" * 7).fold!(3)).to eq "aaa\r\n aa\r\n aa"
    end
    it "should use the passed in fold string" do
      expect(("a" * 7).fold!(3,0,'-***-')).to eq "aaa-***-aa-***-aa"
    end
    it "should handle a custom fold string affect size" do
      expect(("a" * 20).fold!(10,0,'-----',5)).to eq "aaaaaaaaaa-----aaaaa-----aaaaa"
    end
  end
end
