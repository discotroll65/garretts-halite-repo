$:.unshift(File.dirname(__FILE__))
require 'networking'
require 'pry-byebug'

# because we gem installed pry-byebug, we can put binding.pry in here to debug
# however, the network seems to override the STDOUT stream, so won't be useful
# unless you modify networking.rb
# binding.pry
network = Networking.new("RubyBot")
tag, map = network.configure
while true
  moves = []
  map = network.frame

  (0...map.height).each do |y|
    (0...map.width).each do |x|
      loc = Location.new(x, y)
      site = map.site(loc)

      if site.owner == tag
        moves << Move.new(loc, GameMap::DIRECTIONS.shuffle.first)
      end
    end
  end

  network.send_moves(moves)
end
