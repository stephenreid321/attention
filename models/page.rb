class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  page_ids = []

  oauth_access_token = 'EAACEdEose0cBABNJN53CXHeZCz0CXn1erj8WhPyC8wYBAwFfcowqrcOlHCDusOrfqUm52QW3WPDAsaX5OX1OFKfB0GIOXk0JjI1e9WSSRZCajtKfU3zLxuHnmtI64jJnGeWyH2FFWE5O2ywsT2NjpnKnQzDtsUunCeF6RCNl6EZCbA0RZCcOD7y1UqryxDsa9RzbtiFpvgZDZD'
  @graph = Koala::Facebook::API.new(oauth_access_token)
  likes = @graph.get_connections('me', 'likes')
  while likes
    likes.each { |page| page_ids << page['id'] }
    likes = likes.next_page
  end

  page_ids.each_with_index { |page_id,i|
    puts "#{i+1}/#{page_ids.count}"
    page = a.get("https://m.facebook.com/#{page_id}")
    unfollow = page.link_with(:href => /page\/follow_mutator/)
    unfollow.click if unfollow
  }  
    
end
