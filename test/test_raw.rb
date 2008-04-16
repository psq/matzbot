require File.join(File.dirname(__FILE__), "helper")

context "A Raw object created from a /msg to a user" do
  
  before(:each) do
    @msg = ':automatthew!n=matthew@10.0.0.5 PRIVMSG ab5tract :this is a message only to ab5tract'
    @raw = MatzBot::Raw.new(@msg)
  end
  
  specify "has a type" do
    @raw.type.should == :msg
  end
  
  specify "has a sender" do
    @raw.sender.should == {:nick=>"automatthew", :name=>"n=matthew", :hostmask=>"10.0.0.5"}
  end
  
  specify "has a recipent" do
    @raw.to.should == "ab5tract"
  end
  
  specify "has a body" do
    @raw.body.should == "this is a message only to ab5tract"
  end
  
end