require File.join(File.dirname(__FILE__), "helper")

context "The thingamabob we're testing" do
  
  before(:each) do
    @whatsit = "Foo"
  end
  
  specify "does some things we want it to" do
    @whatsit.should == "Foo"
  end
  
end