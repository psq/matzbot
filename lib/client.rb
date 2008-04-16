require 'socket'

module MatzBot

  # Class: Raw
  # Desc:  This class represents the raw IRC commands coming in through the socket.
  class Raw
    attr_accessor :sender, :body, :type, :to, :raw

    def initialize(raw)
      return unless match = raw.match(Raw.pm_regex)
      @type = :msg
      self.typer(match)
    end
    
    def self.pm_regex
      @pm_regex ||= /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG \#?(\w+) \:(.+)/
    end
    
    def typer(raw)
      self.sender = { :nick => raw[1], :name => raw[2], :hostmask => raw[3] }
      self.to     = raw[4]
      self.body   = raw[5]
      self.raw    = raw[0]
    end
  end

    # Class: Bot
    # Desc: This Bot class exists for the sake of extensibility (multiple bots in the future, etc)
    #       and so connect! looks a bit less flustered.
  class Bot
    attr_accessor :server, :port, :nick, :name, :user, :pass, :chan
      
    def initialize(config)
      self.server = config[:server]
      self.port   = config[:port]
      self.user   = config[:user]
      self.nick   = config[:nick]
      self.pass   = config[:password]
      self.chan   = config[:channel]
      self.name   = config[:name]
    end
  end

  module Client
    extend self

    attr_accessor :config, :socket, :last_nick, :authorized

    # put our regexp's together outside of the instances they are used
    @privmsg = /^\:(.+)\!\~?(.+)\@(.+) PRIVMSG \#?(\w+) \:(.+)/


    def start(options)
      self.config ||= {}
      self.config.merge! Hash[*options.map { |k,v| [k.intern, v] }.flatten]

      connect!
      main_loop
    end

    def connect!
      x = Bot.new(config)
      
      log "Connecting to #{x.server}:#{x.port}..."

      self.socket = TCPSocket.new(x.server, x.port)


      socket.puts "USER #{x.user} #{x.nick} #{x.name} :#{x.name} \r\n"
      socket.puts "NICK #{x.nick} \r\n"

      socket.puts "PRIVMSG NickServ :IDENTIFY #{x.pass}" if x.pass
      
      # channel does not have a # in front of it, so add it
      x.chan = x.chan[/^#/] ? x.chan : '#' + x.chan
      join x.chan
    end

    def reconnect!
      socket.close
      self.socket = nil
      start
    end
    
    def main_loop
      while true
        if IO.select([socket])
          react_to socket.gets
        end
      end
    end

    def react_to(line)
      begin
        MatzBot.reload!
      rescue Exception => bang 
        say "Class load error #{bang.class} (#{caller[1]}), #{bang}."
      end      

      self.authorized = false # not authorized

      info = grab_info(line) # grabs the info from an PRIVMSG
      puts line              # puts to the console

      #l && info ? l.update(info) : l.new(info)

      l = Raw.new(line)
      puts "from the Raw class: #{l.body}" if l.body

      pong(line) if line[0..3] == "PING" # keep-alive

      if info && info[-1]    # only called if grabbing the info was successful
        log_message info    # logs in a friendly format, in chat.txt
        
        info.to_a.each {|x| puts "\n#{x}"}
        
        execute(info[-1], info[0]) if info
      elsif has_error?(line)
        reconnect! 
      end
    end

    def has_error?(line)
      log "Error from server: #{line}" and return true if line[/^ERROR/]
    end
    
    def execute(cmd, nick)
      data = cmd.split
      return false unless data && data.first && authorize?(data)

      self.last_nick = nick

      data.join(' ').split(' then ').each do |command|
        # callbacks
        filters(:listen).each do |filter|
          filter.call(command) if command
        end if filters(:listen).size.nonzero?

        command = command.split(' ')
        command.shift if command.first =~ /^#{config[:nick]}/i

        if Commands.methods.include? command.first and !(EmptyModule.methods.include? command.first)
          Commands.send(command.first, command[1..-1])
        #else
        #  say "no command #{command}"
        end
      end
    rescue Exception => bang
      say "Command error #{bang.class}, #{bang}."
      say " #{bang.backtrace.first}"
    end

    def say(message)
      Commands.say message
    end

    def filters(type)
      Commands.send(:filters, type)
    end
    
    def pong(line)
      line[0..3] = "PONG"
      socket.puts "#{line}"
      puts "#{line}"
      Commands.poll(line) if Commands.methods.include? 'poll'
    end
    
    def grab_info(text)
      # The following is the format of what the bot recieves:
      # :kyle!~kyle@X-24735511.lmdaca.adelphia.net PRIVMSG #youngcoders :for the most part
      # :nick!~ident@host PRIVMSG #channel :message
      text =~ @privmsg ? Regexp.last_match : false
    end
    
    def authorize?(data)
      if self.config[:only_when_addressed] and data.first != "#{self.config[:nick]}:"
        return false
      end
      
      command, password = data.first, data[1]
      if Commands.protected_instance_methods(false).include? command
        self.authorized = config[:password] && password == config[:password]
        data.delete_at(1) 
        authorized
      else true
      end
    end
    
    def join(channel, quit_prev = true)
      socket.puts "PART #{config[:channel]}" if quit_prev
      socket.puts "JOIN #{channel} \r\n"
      config[:channel] = channel
    end
    
    def log_message(array)
      log "<#{array[0]}> : #{array[4]}"
    end

    def log(string)
      File.open("chat.txt", "a") do |f|
        f.puts "[#{Time.new.strftime "%m/%d/%Y %I:%M %p PST"}] #{string} \n"
      end
    end
  end
end

module EmptyModule
end

