require 'helper'
class TestGumroadable < Test::Unit::TestCase
  should "assert configuration is value" do
    Gumroadable.config do |config|
      config.email = "dude@test.com"
      config.password = "test1234"
    end    
    assert Gumroadable.config.email == "dude@test.com"
    assert Gumroadable.config.password == "test1234"
  end
  
  should "save" do
    m = TestModel.new(
      :name => "My product", 
      :price => 9.99,
      :description => "I love college!",
      :slug => "my-product",
      :tag_list => "stuff")
    m.expects(:client).returns(pho_client)
    m.save
    assert m.gumroad_id == "12345"
    assert m.variants.empty?
    assert TestModel.data.call(m)[:name] == "My product"
  end
  
  should "have correct variants" do
    m = TestModel.new(
      :name => "My product", 
      :price => 9.99,
      :description => "I love college!",
      :slug => "my-product",
      :tag_list => "surf boards,clothes,guitars")
    assert m.variants.length == 1, "Should have 1 variant"
    assert m.variants[0] == {name: "adult sizes", options: [{name: "S"},{name: "M"},{name: "L"},{name: "XL"}, {name: "XXL"}]}, "Should be the adult size variant"
  end
  
  should "call delete if an attribute changes" do
    m = TestModel.new(
      :name => "My product", 
      :price => 9.99,
      :description => "I love college!",
      :slug => "my-product",
      :tag_list => "surf boards,clothes,guitars")
    m.expects(:client).at_least_once.returns(pho_client)
    m.save
    m.gumroad_synced = false
    assert m.gumroad_id == "12345"
    m.price = 10.99
    m.expects(:delete_gumroad).returns(true)
    m.save
    assert m.price == 10.99
    assert m.gumroad_id == "54321"
  end
  
  def pho_client()
    pho_link = mock()
    pho_link.expects(:id).at_least_once.returns("12345").then.returns("54321")
    pho_links  = mock()
    pho_links.expects(:create).at_least_once.returns(pho_link)
    pc = mock()
    pc.expects(:links).at_least_once.returns(pho_links)
    pc
  end
end
