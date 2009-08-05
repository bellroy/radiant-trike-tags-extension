require File.dirname(__FILE__) + '/../spec_helper'

describe ContentScanner do
  it "should be loaded" do
    lambda { ContentScanner }.should_not raise_error
  end
  it "should alias #find to #find_replace" do
    ContentScanner.should_receive(:find_replace).with(:find)
    ContentScanner.find(:find)
  end
  it "should alias #replace to #find_replace" do
    ContentScanner.should_receive(:find_replace).with(:find, :replace)
    ContentScanner.replace(:find, :replace)
  end
  describe "#find_replace" do
    it "should iterate through all PageParts" do
      PagePart.should_receive(:find).with(:all).and_return([])
      ContentScanner.find_replace(:find)
    end
    it "should search all PagePart #content" do
      page_part = mock("page_part")
      page_part.should_receive(:content).at_least(2).times.and_return("")
      PagePart.stub!(:find).and_return([page_part, page_part])
      ContentScanner.find_replace("find")
    end

    describe "without replace" do
      it "should find exact text matches in PageParts and return matching pages" do
        match = mock("part with match", :null_object => true, :content => "containing a thing |here|.", :id => 42)
        nonmatch = mock("part without match", :null_object => true, :content => "not containing the thing.")
        PagePart.stub!(:find).and_return([match, nonmatch])

        ContentScanner.find_replace("here").should == [match]
      end
      it "should puts summary of what was found"
    end
    describe "with replace" do
      it "should replace exact text matches in PageParts and return matching pages" do
        match = mock("part with match", :null_object => true, :content => "containing a thing |here|.", :id => 42)
        nonmatch = mock("part without match", :null_object => true, :content => "not containing the thing.")
        PagePart.stub!(:find).and_return([match, nonmatch])
        match.should_receive(:update_attribute).with(:content, "containing a thing |there|.")

        ContentScanner.find_replace("here", "there").should == [match]
      end
      it "should puts summary of what was replaced"
    end
  end
end
