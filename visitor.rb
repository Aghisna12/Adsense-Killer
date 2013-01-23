#!/usr/bin/env ruby 
require 'rubygems'
require 'mechanize'

class Visitor
  def initialize(proxy_file, url, iterations)
    @proxy_file = proxy_file
    @url = url
    @iterations = iterations
  end

  def get_proxies
    proxies = []
    File.open(@proxy_file, "r").each_line do |line|
      tokens = line.split(":")
      proxy = { ip: tokens[0], port: tokens[1].delete("\n") }
      proxies << proxy
    end
    return proxies
  end

  def run
    proxies = get_proxies
    (1..@iterations.to_i).each do |i|
      user_agent = Mechanize::AGENT_ALIASES.keys.sample
      proxy = proxies.sample
      mech_agent = Mechanize.new
      mech_agent.user_agent_alias = user_agent
      mech_agent.set_proxy proxy[:ip], proxy[:port]
      puts "[#{i}]Visit " << @url << " as " << user_agent << " @ " << proxy[:ip] << ":" << proxy[:port]
      begin
        page = mech_agent.get(@url)
      rescue
        puts "Failed! Removing " << proxy[:ip] << ":" << proxy[:port] 
        proxies.delete_if { |hash| hash[:ip] == proxy[:ip] && hash[:port] == proxy[:port] }
      end
    end
  end
end

# e.g. ruby .\thisscript.rb .\proxies.txt http://google.com 1000
if __FILE__ == $PROGRAM_NAME
  visitor = Visitor.new ARGV[0], ARGV[1], ARGV[2]
  visitor.run
end