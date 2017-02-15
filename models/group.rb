class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  # $('#GroupDiscoverCard_membership ._4-u3 ._266w a').each(function() {
  #   console.log($(this).attr('data-hovercard').split('?id=')[1].split('&')[0])
  # })  
    
  def leave
    ### leave  
    # page = a.get("https://m.facebook.com/group/leave/?group_id=#{group_id}&refid=18")
    # form = page.form_with(:action => '/a/group/leave/')
    # form ? form.submit : (puts "missing: #{group_id}")
  end
  
  def notification_level
    ### notification settings. level 2 - friends, level 3 - all   
    page = a.get("https://m.facebook.com/group/settings/?group_id=#{group_id}&refid=18")
    form = page.form_with(:action => "/a/group/settings/?group_id=#{group_id}")
    form.radiobutton_with(:name => 'level', :value => '2').check
    form.submit
  end
    
end
