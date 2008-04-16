require File.join(File.dirname(__FILE__), "helper")

context "A Raw object created from a /msg to a user" do
  
  before(:each) do
    @msg1 = ':automatthew!n=matthew@10.0.0.5 PRIVMSG ab5tract :this is a message only to ab5tract'
    @raw_pm = MatzBot::Raw.new(@msg1)
    
    @msg2 = ':automatthew!n=matthew@10.0.0.5 PRIVMSG #waves :this is a message only to #waves'
    @raw_chan = MatzBot::Raw.new(@msg2)
  end
  
  specify "has a type" do
    @raw_pm.type.should == :pm
    @raw_chan.type.should == :chan
  end
  
  specify "has a sender" do
    @raw_pm.sender.should == {:nick=>"automatthew", :name=>"n=matthew", :hostmask=>"10.0.0.5"}
  end
  
  specify "has a recipent" do
    @raw_pm.to.should == "ab5tract"
  end
  
  specify "is channel message" do
    @raw_chan.to.should =~ /\A#/
  end
  
  specify "has a body" do
    @raw_pm.body.should == "this is a message only to ab5tract"
  end
  
end