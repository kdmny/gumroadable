require 'active_record'
require "gumroadable/methods"
module Gumroadable
  VERSION="0.0.1"
  #config stuffs
  @@config = nil
  
  def self.config(new_config=nil)
    first_time = @@config.nil?
    @@config ||= OpenStruct.new((YAML.load_file(config_dir.join("gumroad.yml"))[config_env] rescue {}))        
    set_config(new_config) if new_config
    yield(@@config) if block_given?
    @@config    
  end
  
  private
  
  def self.config_env
    return Rails.env if defined?(Rails)
    nil
  end
  
  def self.config_dir
    return Rails.root.join("config") if defined?(Rails)
    Pathname.new("config")
  end
  
  def self.set_config(new_config)
    new_config.each{|k,v| @@config.send(:"#{k}=", v) if !v.nil?}
  end
end