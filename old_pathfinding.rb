

class PathNode
  attr_reader :x, :y, :ex, :ey
  attr_reader :f, :g, :h, :parent
  
  def initialize( x,y,ex,ey, parent )
    @x = x
    @y = y
    @ex = ex
    @ey = ey
    @parent = parent
    
    pg = 0
    if parent
      pg = parent.g
    end
    
    @g = pg + 10
    @h = ((@x-@ex).abs + (@y-@ey).abs)*10
    @f = @g+@h
  end
  
  def equal?( other )
    return true if other.x == @x and other.y == @y
    false
  end
  
  def is_at?( x,y )
    (x == @x and y == @y)
  end
  
  def to_s
    "#{@x},#{@y}"
  end
  
  def step
    [@x,@y]
  end
  
end

class PathWork
  
  def initialize( owner, map, sx,sy,ex,ey, method = :astar  )
    @owner = owner
    @sx = sx
    @sy = sy
    @ex = ex
    @ey = ey
    @map = map
    @method = method
    
    @done = false
    
    @open = []
    @closed = []

    #score = ((sx-ex).abs + (sy-ey).abs)*10
    #@open << [@sx,@sy,nil,score,0,score]
    @open << PathNode.new( sx,sy, ex,ey, nil)
    
    puts "Planning path from #{sx},#{sy} to #{ex},#{ey}"
    
    #tick()
    @start_time = Time.now.to_i
  end
  
  
  def draw( cam )
    @open.each do |n|
      if n.parent
        sx = ((n.parent.x-cam.x)*8)+4
        sy = ((n.parent.y-cam.y)*8)+4
        ex = ((n.x-cam.x)*8)+4
        ey = ((n.y-cam.y)*8)+4
        $win.draw_line( sx,sy,0xFF00FF00, ex,ey, 0xFF009900, ZOrder::UI )
      end
    end

    @closed.each do |n|
      if n.parent
        sx = ((n.parent.x-cam.x)*8)+4
        sy = ((n.parent.y-cam.y)*8)+4
        ex = ((n.x-cam.x)*8)+4
        ey = ((n.y-cam.y)*8)+4
        $win.draw_line( sx,sy,0xFFFF0000, ex,ey, 0xFFFF0000, ZOrder::UI )
      end
    end
  end
  
  def done!
    puts "Yay!"
    @done = true
  end
  
  def fail!
    puts "No path!"
    @done = true
    @owner.on_telegram( :no_path, [@ex,@ey] )
  end
  
  def done?
    @done
  end
  
  
  def tick()
    return if done?
    
    time_taken = Time.now.to_i - @start_time
    if time_taken > 10
      puts "Enough time wasted on pathfinding!"
      fail!
    end
    
    5.times do
      do_astar
    end
  end
  
  
  def construct_path( from )
    
    path = []
    while from.parent 
      path << from.step
      from = from.parent
    end
    
    @owner.on_telegram( :path_found, path.reverse )
  end
  
  
  def do_astar
    return if done?

    @open.sort! { |a,b| a.f <=> b.f }
    
    n = @open.shift
    @closed << n
    
    if not n
      fail!
      return
    end
    
    if n.is_at?( @ex,@ey )
      done!
      construct_path(n)
      return
    end
    
    #puts "Considering #{n}. Closed length: #{@closed.length}"

    add_astar_search(n.x-1,n.y, n)
    add_astar_search(n.x+1,n.y, n)
    add_astar_search(n.x,n.y-1, n)
    add_astar_search(n.x,n.y+1, n)
    
    

  end
  
  def add_astar_search( nx,ny, parent )
    
    return if @map.outside?(nx,ny)
    return if @map.solid?(nx,ny)
    
    n = PathNode.new( nx,ny, @ex,@ey, parent )
    
    (@open+@closed).each do |t|
      return if t.equal?( n )
    end
    
    @open << n
        
  end
  
  
end


class PathPlanner

  @@work = []

  def PathPlanner.find( who, map, sx,sy, ex,ey )    
    @@work << PathWork.new( who,map, sx,sy,ex,ey )
  end

  def PathPlanner.tick
    @@work.delete_if do |w|
      w.tick
      w.done?
    end
  end

  def PathPlanner.draw( cam )
    @@work.each do |w|
      w.draw cam
    end
  end

end