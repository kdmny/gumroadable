require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'gumroadable'

class Test::Unit::TestCase
end

class TestModel < ActiveRecord::Base
  gumroadable :data => Proc.new{|p|
    {
      name: p.name,
      url: "http://localhost/item/#{p.slug}",
      description: p.description, 
      price: (p.price*100).to_i.to_s,
      variants: p.variants.to_json,
      require_shipping: true,
      preview_url: "http://placehold.it/300x250"
    }
  }, :variant_fns => [
    Proc.new{|p|      
      if (p.tag_list.split(",") & ["workout clothes", "clothes", "maternity clothes"]).any?
        {name: "adult sizes", options: [{name: "S"},{name: "M"},{name: "L"},{name: "XL"}, {name: "XXL"}]}
      end
    },
    Proc.new{|p|
      if (p.tag_list.split(",") & ["baby clothes"]).any?
        {name: "kid sizes", options: [{:name => "0-3 MONTHS"}, {:name => "3-6 MONTHS"}, 
        {:name => "6-9 MONTHS"}, {:name => "6-12 MONTHS"}, {:name => "12-18 MONTHS"}, 
        {:name => "12-24 MONTHS"}, {:name => "18-24 MONTHS"}, {:name => "2T (2 YEARS)"}, 
        {:name => "2T-3 (2-3 YEARS)"}, {:name => "3 (3 YEARS)"}, {:name => "4 (4 YEARS)"}]}        
      end
    }
  ]
  attr_accessor :tag_list
end
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)
ActiveRecord::Schema.define do
  self.verbose = false
  create_table :test_models, :force => true do |t|
    t.string :gumroad_id
    t.string :name
    t.string :description
    t.float  :price
    t.string :slug
  end
end
require "mocha/setup"
