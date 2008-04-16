require File.join(File.dirname(__FILE__), "helper")

context "The thingamabob we're testing" do
  
  before(:each) do
    @match = ":automatthew!n=matthew@76.210.108.157 PRIVMSG #matzbot :-Okay.  do you have a good example?"
    @no_match = ":heinlein.freenode.net PONG heinlein.freenode.net :LAG15568992"
  end
  
  specify "does some things we want it to" do
    MatzBot::Client.grab_info(@match).should.be.a.kind_of MatchData
    MatzBot::Client.grab_info(@no_match).should == false
  end
  
end