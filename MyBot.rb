$:.unshift(File.dirname(__FILE__))
require 'networking'
VECTORS = {
  east: [1, 0],
  west: [-1, 0],
  north: [0, -1],
  south: [0, 1],
}
NETWORK = Networking.new("RubyBot")
def adj_top_prod_site(current_map, loc)
  adjacent_sites = get_all_adjacent_sites()
  site_returning = nil

  adjacent_sites.each do |site_hash|
    site_returning = site_hash if site_ash[:site].production = 8
  end

  return site_returning
end

def get_relative_direction_of_adj(site_loc, adj_site_loc, current_map)
  width = current_map.width
  height = current_map.height

  if (adj_site_loc.x - site_loc.x) > 1
    x_vector = (adj_site_loc.x - site_loc.x) - width
  elsif (adj_site_loc.x - site_loc.x) < -1
    x_vector = width + (adj_site_loc.x - site_loc.x)
  else
    x_vector = (adj_site_loc.x - site_loc.x)
  end

  if (adj_site_loc.y - site_loc.y) > 1
    y_vector = (adj_site_loc.y - site_loc.y) - height
  elsif (adj_site_loc.y - site_loc.y) < -1
    y_vector = height - (adj_site_loc.y - site_loc.y)
  else
    y_vector = (adj_site_loc.y - site_loc.y)
  end

  cardinal_returning = nil
  vector = [x_vector, y_vector ]
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
  width = current_map.width
  height = current_map.height

  if (loc.x + vector[0]) >= width
    new_x = (loc.x + vector[0]) - width
  elsif (loc.x + vector[0]) < 0
    new_x = width + (loc.x + vector[0])
  else
    new_x = loc.x + vector[0]
  end

  if (loc.y + vector[1] >= height )
    new_y = (loc.y + vector[1]) - height
  elsif (loc.y + vector[1] < 0 )
    new_y = height + loc.y + vector[1]
  else
    new_y = loc.y + vector[1]
  end

  adj_loc = Location.new(new_x, new_y)
  # NETWORK.log("adj_loc is  #{adj_loc.inspect}")
  site = current_map.site(adj_loc)
  {site: site, loc: adj_loc}
end

def find_adj_empty_sites(current_map, loc)
  adj_sites = get_all_adjacent_sites(current_map, loc)
  # NETWORK.log("adjacent sites are #{adj_sites.inspect}")
  empty_adj_sites = []

  adj_sites.each do |site_hash|

    empty_adj_sites << site_hash if site_hash[:site].owner == 0
  end

  empty_adj_sites

end

def is_row_owned?(cur_map, cur_loc, tag)
  own_all = true
  fixed_height = cur_loc.y
  0...cur_map.width do |row|
    site = cur_map.site(Location.new(row, fixed_height))
    own_all = false if site.owner != tag
  end
  own_all
end

def is_row_high_prod?(cur_map, cur_loc)
  high_prod = false
  fixed_height = cur_loc.y
  0...cur_map.width do |row|
    site = cur_map.site(Location.new(row, fixed_height))
    high_prod = true if site.production >= 8
  end
  high_prod
end



network = NETWORK
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
          if site.strength >= 100
            row_owned = is_row_owned?(map,loc, tag)
            high_prod_row = is_row_high_prod?(map,loc)
            if row_owned && high_prod_row
              moves << Move.new(loc, :west)
            else
              row_owned ? moves << Move.new(loc, :north) : moves << Move.new(loc, :west)
            end
          else
            moves << Move.new(loc, :still)
          end
        else

          adj_empty_sites.sort!{ |x,y| y[:production] <=> x[:production]  }
          moved = false



          adj_empty_sites.each do | empty_site_hash|
            will_survive = site.strength > empty_site_hash[:site].strength
            if will_survive && !moved
              top_prod = adj_empty_sites[0][:site].production
              #worth waiting if more than one option, and best option is 4 or more and better than current on
              worth_waiting = adj_empty_sites.length > 1 && top_prod >= 4 && empty_site_hash[:site].production < top_prod
              if !(worth_waiting)
                card = get_relative_direction_of_adj(loc, empty_site_hash[:loc], map)
                if site.strength == 255 && !( [:north,:east,:west, :south].include?(card) )
                  NETWORK.log("Card of #{loc.x}, #{loc.y} is sites are #{card}")
                end
                moves << Move.new(loc, card )
                moved = true
              end
            end
          end

          moves << Move.new(loc, :still) if !moved
        end
      end
    end
  end

  network.send_moves(moves)
end
