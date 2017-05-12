$:.unshift(File.dirname(__FILE__))
require 'networking'
VECTORS = {
  east: [1, 0],
  west: [-1, 0],
  north: [0, -1],
  south: [0, 1],
}

def adj_top_prod_site(current_map, loc)
  adjacent_sites = get_all_adjacent_sites()
  site_returning = nil

  adjacent_sites.each do |site_hash|
    site_returning = site_hash if site_ash[:site].production = 8
  end

  return site_returning
end

def get_relative_direction_of_adj(site_loc, adj_site_loc)
  cardinal_returning = nil
  vector = [adj_site_loc.x - site_loc.x , adj_site_loc.y - site_loc.y ]
  VECTORS.keys.each do |key|
    cardinal_returning = key if VECTORS[key] == vector
  end

  cardinal_returning
end

def get_all_adjacent_sites(current_map, loc)
  adjacent_sites = []
  adjacent_sites << get_adjacent_site(current_map, loc, VECTORS[:east])
  adjacent_sites << get_adjacent_site(current_map, loc, VECTORS[:west])
  adjacent_sites << get_adjacent_site(current_map, loc, VECTORS[:north])
  adjacent_sites << get_adjacent_site(current_map, loc, VECTORS[:south])
  adjacent_sites
end

def get_adjacent_site(current_map, loc, vector)
  adj_loc = Location.new(loc.x + vector[0], loc.y + vector[1])
  site = map.site(adj_loc)
  {site: site, loc: adj_loc}
end

def find_adj_empty_sites(current_map, loc)
  adj_sites = get_all_adjacent_sites(current_map, loc)
  empty_adj_sites = []

  adj_sites.each do |site_hash|
    empty_adj_sites << site_hash if site_hash[:site].owner == 0
  end

end



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
        adj_empty_sites = find_adj_empty_sites(map, loc)
        if adj_empty_sites.length == 0
          site.strength >= 100 ? moves << Move.new(loc, :west) : moves << Move.new(loc, :still)
        else
          adj_empty_sites.sort!{ |x,y| y[:production] <=> x[:production]  }
          moved = false
          adj_empty_sites.each do | empty_site_hash|
            will_survive = site.strength > empty_site_hash[:site].strength
            if will_survive && !moved
              moves << Move.new(loc, get_relative_direction_of_adj(loc, empty_site_hash[:loc]) )
              moved = true
            end
          end

          moves << Move.new(loc, :still) if !moved
        end
      end
    end
  end

  network.send_moves(moves)
end
