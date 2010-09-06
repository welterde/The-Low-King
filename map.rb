
MAP_WIDTH = 128
MAP_HEIGHT = 128


AIR = 0
DIRT = 1
ROCK = 2





class Map


  def initialize

    @data = Array.new( MAP_WIDTH*MAP_HEIGHT )

    MAP_WIDTH.times do |x|
      MAP_HEIGHT.times do |y|
        set_data( x,y, :blocks=>[AIR,DIRT], :seen => false, :selected => false )
        
        #set_tile( x,y, [AIR,DIRT] )
        
        set_tile(x,y, [ROCK,ROCK] ) if x >= MAP_WIDTH/4
          
      end
    end

    @tilemap = Gosu::Image.load_tiles($win, "data/tilemap.png", 8,8, true)
    @tilemap[0].retro! 
  end
  
  
  def save( filename )
  
    File.open(filename,'w') do |f|
      f.puts "LKFV1"
      f.puts "#{MAP_WIDTH}:#{MAP_HEIGHT}"
      f.puts Marshal.dump( @data, f )
    end
    
  end
  
  
  def load( filename )
    
    File.open(filename,'r') do |f|
      header = f.readline.chop
      return false,"Not a valid mapfile" if header != "LKFV1"
      sizestr = f.readline.chop
      nmw,nmh = sizestr.split(':')
      return false,"Map size does not match constant mapsize" if nmw.to_i != MAP_WIDTH and nmh.to_i != MAP_HEIGHT
      @data = Marshal.load( f )
    end
    
    return true,nil
  end
  
  
  def outside?(x,y)
    return true if x < 0 or y < 0 or x >= MAP_WIDTH or y >= MAP_HEIGHT
    false    
  end
  
  def solid?(x,y)
    t = get_tile(x,y)
    
    return false if t[0] == AIR
    
    true
  end
  
  def select( mx,my )
    d = get_data(mx,my)
    d[:selected] = true
    set_data(mx,my, d)
  end
  
  def unselect( mx,my )
    d = get_data(mx,my)
    d[:selected] = false
    set_data(mx,my, d)
  end
  
  def selected?(mx,my)
    d = get_data(mx,my)
    d[:selected]
  end
  

  def get_data( x,y )
    i = y*MAP_WIDTH+x
    @data[i]
  end
  
  def set_data( x,y, d )
    i = y*MAP_WIDTH+x
    @data[i] = d
  end

  def get_tile( x,y )
    return nil if x < 0 or y < 0 or x >= MAP_WIDTH or y >= MAP_HEIGHT
    d = get_data(x,y)
    d[:blocks]
  end


  def set_tile( x,y, v )
    return if x < 0 or y < 0 or x >= MAP_WIDTH or y >= MAP_HEIGHT
    
    d = get_data(x,y)
    d[:blocks] = v
    set_data(x,y, d)
  end
  
  
  def find_free_spots( x,y )
    spots = []
    spots << [x-1,y] if not solid?(x-1,y)
    spots << [x+1,y] if not solid?(x-1,y)
    spots << [x,y-1] if not solid?(x,y-1)
    spots << [x,y+1] if not solid?(x,y+1)

    return spots
  end
  
  def find_closest_spot( x,y, ox,oy )
    spots = find_free_spots(x,y).sort do |a,b|
      d1 = Gosu::distance( ox,oy, a[0],a[1] )
      d2 = Gosu::distance( ox,oy, b[0],b[1] )
      d1 <=> d2
    end
    
    spots[0]
  end
  
  
  def mine( x,y, who )
    
    t = get_tile( x,y )
    mined = t[0]
    t[0] = AIR
    set_tile( x,y, t )    
    
    r = nil
    case mined
    when ROCK
      puts "ROCK mined, resource drop at #{x},#{y}"
      r = ResourceRock.new( :x => x, :y => y )
    else
      puts "Unknown resource type: #{mined}"
    end
    
    if r
      # Create a job to place this resource at the stockpile
      # TODO: create stockpile... For now, place it near 5,3
      JobCollect.new( :x => x, :y => y, :tx => 5, :ty => 3 )
    end
    
  end


  def draw( x,y )

    20.times do |lx|
      mx = x+lx
      sx = lx*8
      13.times do |ly|
        my = y+ly
        sy = ly*8

        tile =  get_tile(mx,my)
        data = get_data(mx,my)
        if tile
          block = tile[0]
          floor = tile[1]

          if block != AIR
            #puts "#{block}"
            @tilemap[block].draw( sx,sy, ZOrder::WALL )
            if data[:selected]
              c = 0x77FFFFFF
              $win.draw_quad( sx,sy,c, sx+8,sy,c, sx,sy+8,c, sx+8,sy+8,c, ZOrder::WALL )
            end
            
          else
            @tilemap[floor].draw( sx,sy, ZOrder::FLOOR,1,1, 0xffaaaaaa )
          end
        end

      end
    end

  end



end