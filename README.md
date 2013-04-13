gumroadable
==========

Simplifying [Gumroad](http://gumroad.com) management for Rails apps.

Installation
==========

In your Gemfile:

  gem 'gumroadable'

`gumroadable` expects that your model will have 2 fields: `gumroad_id` (string) and `price` (float).

In your model:

```ruby
class Product < ActiveRecord::Base
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
        {
          name: "adult sizes", 
          options: [{name: "S"},{name: "M"},{name: "L"},{name: "XL"}, {name: "XXL"}]
        }
      end
    },
    Proc.new{|p|
      if (p.tag_list.split(",") & ["baby clothes"]).any?
        {
          name: "kid sizes", 
          options: [
            {:name => "0-3 MONTHS"}, {:name => "3-6 MONTHS"}, 
            {:name => "6-9 MONTHS"}, {:name => "6-12 MONTHS"}, {:name => "12-18 MONTHS"}, 
            {:name => "12-24 MONTHS"}, {:name => "18-24 MONTHS"}, {:name => "2T (2 YEARS)"}, 
            {:name => "2T-3 (2-3 YEARS)"}, {:name => "3 (3 YEARS)"}, {:name => "4 (4 YEARS)"}
          ]
        }        
      end
    }
  ]
...
end
```

The `gumroadable` method takes a hash with 2 required keys:

* `:data` defines what is sent to Gumroad based on their [links API](https://gumroad.com/api/methods#post-/links).

* `:variant_fns` is an array of Procs that are passed the model instance on evaluation. The resulting hashes are passed to Gumroad as variants.

Now anytime you create a new instance of your model OR update any of the fields listed in the :data Proc, the gem will
automatically synchronize the product info with gumroad and save the `gumroad_id` into the model.

If you model responds to the `delay` method, perhaps from Resque, the synchronization will be queued.
  
Design Decisions
============

It was easier to perform an update by deleting the old product and creating a new one so that's how this gem handles updates.

Contributing to gumroadable
============
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
============

Copyright (c) 2013 K$. See LICENSE.txt for
further details.

