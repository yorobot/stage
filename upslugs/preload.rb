##########
#  to run use:
#   $ ruby upslugs/preload.rb


require_relative 'helper'


Webget.config.sleep = 2



def preload( slug )
  ## note: check if passed in slug is cached too (if not - preload / download too)
  url = Worldfootball::Metal.schedule_url( slug )

  cached = false

  if Webcache.cached?( url )
    print "   OK "
    cached = true
  else
    Worldfootball::Metal.download_schedule( slug )
    print "      "
  end


   print "%-46s" % slug

   if cached
     ## do NOT read if cached for now
     ##   to speed-up preload
   else
     page = Worldfootball::Page::Schedule.from_cache( slug )

     ## clean-up title/strip "» Spielplan" from title
     print '  /  '
     print page.title.sub('» Spielplan', '').strip
   end
=begin
   print '  -  '
   ## check for match count
   matches = page.matches
   print "#{matches.size} match(es)"
=end
   print "\n"
end # method preload


keys = Worldfootball::LEAGUES.keys




keys.each_with_index do |key, i|

  league = Worldfootball::LEAGUES[key]

  seasons = league.seasons

  puts "==> #{i+1}/#{keys.size} #{key} - #{seasons.size} seasons(s)..."

  seasons.each_with_index do |season_rec,j|
    season = season_rec[0]
    pages = league.pages( season: season )
    puts "  #{j+1}/#{seasons.size} #{key} #{season} - #{pages.size} page(s)..."
    pages.each do |slug,_|
      preload( slug )
    end
  end
end


puts "bye"
