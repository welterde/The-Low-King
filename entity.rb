

class Entity
  @@tiles = nil
  @@list = []
  
  def Entity.pick( mx,my )
    picked = []
    @@list.each do |e|
      picked << e if e.x == mx and e.y == my
    end
    picked
  end
  
  def Entity.get_resource( mx,my )
    picked = Entity.pick(mx,my)
    picked.delete_if { |r| not r.kind_of? Resource  }
    picked
  end
  
  def Entity.draw_all( cam )
    @@list.each do |e|
      e.draw cam
    end
  end
  
  def Entity.tick_all
    @@list.each do |e|
      e.tick
    end
  end
  
  attr_reader :x, :y
  
  def initialize( options = {})
  
    if not @@tiles
      @@tiles = Gosu::Image.load_tiles($win, "data/entities.png", 8,8, true)
    end
    
    @zorder = ZOrder::ITEM
    
    @hidden = false
    
    @x = options[:x] || 0
    @y = options[:y] || 0
    @tile = options[:tile] || 0
    
    @@list << self unless options[:do_not_add]
  end
  
  def tick
    
  end
  
  def draw( cam )
    return if @hidden
    sx = (@x-cam.x) * 8
    sy = (@y-cam.y) * 8
    @@tiles[@tile].draw( sx,sy, @zorder )
  end
  
  def place( nx,ny )
    @x = nx
    @y = ny
  end
  
  def on_telegram( msg, data=nil )
    
  end
  
end