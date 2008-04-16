%w{rubygems}.each do |dep|
  require dep
end

Version = '0.1.0'

task :default => [:test]

begin
  gem 'echoe', '>=2.7'
  require 'echoe'
  Echoe.new('matzbot', Version) do |p|
    p.project = 'matzbot'
    p.summary = "matzbot is nice so we are nice"
    p.author = ["Evan Weaver", "Chris Wanstrath", "Jhn Hltwngr", "Matthew King"]
    p.email = "automatthew@gmail.com"
    p.ignore_pattern = /^(\.git).+/
    p.test_pattern = "test/test_*.rb"
    # p.rcov_options = "-x waves"
  end
rescue
  "(ignored echoe gemification, as you don't have the Right Stuff)"
end
