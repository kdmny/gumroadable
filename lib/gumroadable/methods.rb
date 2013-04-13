require 'gumroad'
module Gumroadable
  module Methods
    def self.included(base)
      base.extend ClassMethods  
    end
    module ClassMethods
      def gumroadable(options={})
        after_save do 
          if respond_to?(:delay)
            delay.sync_gumroad
          else
            sync_gumroad
          end
        end
        class << self
          attr_accessor :data, :variant_fns
        end
        required = [:data, :variant_fns]
        required.each do |r|
          raise Exception.new("gumroadable requires the #{r} option!") if options[r].nil?          
        end
        attr_accessor :gumroad_synced
        @data = options[:data]
        @variant_fns = options[:variant_fns]
        include Gumroadable::Methods::InstanceMethods
      end
    end
    module InstanceMethods
      def sync_gumroad
        return if self.gumroad_synced
        gumroad_attributes.each do |att|
          if (self.send("#{att}_changed?") rescue false)
            delete_gumroad
            self.gumroad_synced = true
            self.gumroad_id = nil
            self.save and return if self.price.blank?
          end
        end unless self.gumroad_id.blank?
        return if self.price.blank?
        d = self.class.data.call(self)
        d.merge!(:variants => self.variants.to_json)
        link = client.links.create(d)
        self.gumroad_id = link.id
        self.gumroad_synced = true
        self.save
      end
      
      def gumroad_attributes
        self.class.data.call(self).keys
      end
      
      def delete_gumroad
        link = ::Gumroad::LinkProxy.new(client).find(self.gumroad_id)
        link.destroy unless link.nil?       
      end
            
      def variants
        self.class.variant_fns.map{|e| e.call(self)}.reject{|e| e.nil?}
      end

      def client
        ::Gumroad.new(
          :email => Gumroadable.config.email, 
          :password => Gumroadable.config.password
        )
      end
    end
  end
end
ActiveRecord::Base.send(:include, Gumroadable::Methods)