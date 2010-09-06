


module PathFinding
  
  def setup
    @requester ||= nil
    @path = []
    @sx ||= 0
    @sy ||= 0
    @ex ||= 0
    @ey ||= 0
    
    @done = false
    @failed = false
  end
  
  def done?
    @done
  end
  
  def failed?
    @failed
  end
  
  def done
    @done = true
  end
  
  def failed
    @done = true
    @failed = true
  end
  
  def on_failure
    # We failed to find a path, so let the requester know that. Include start and end coordinates
    @requester.on_telegram( :no_path, {:from => [@sx,@sy], :to => [@ex,@ey]} )
  end
  
  def on_success
    @requester.on_telegram( :path_found, @path )
  end
  
end




class AStar 
  include PathFinding


  class Node
    attr_accessor :f,:g, :x,:y, :parent
    
    def initialize( x,y,ex,ey, parent )
      @x = x
      @y = y
      @ex = ex
      @ey = ey
      @parent = parent
      @f = 0
      @g = 0
      @h = 0
    end
    
    def calc
      # Manhattan heuristic
      @h = ((@x-@ex).abs + (@y-@ey).abs)
      # Update f
      @f = @g+@h
    end
    
    def to_s
      "#{@x},#{@y}, #{@f}=#{@g}+#{@h}"
    end
    
  end
  
  attr_reader :requester
  
  def initialize( requester, sx,sy, ex,ey )
    setup
    
    @requester = requester
    @sx = sx
    @sy = sy
    @ex = ex
    @ey = ey
    
    @open = []
    @closed = []
    
    start_node = Node.new(@sx,@sy,@ex,@ey,nil)
    start_node.calc
    @open << start_node
    
  end
  
  def draw( cam )
    c = 0xff999999
    @open.each do |n|
      sx = (n.x-cam.x)*8
      sy = (n.y-cam.y)*8
      $win.font.draw( "#{n.f}", sx,sy, ZOrder::UI, 1,1, c )
    end
    c = 0xff000099
    @closed.each do |n|
      sx = (n.x-cam.x)*8
      sy = (n.y-cam.y)*8
      $win.font.draw( "#{n.f}", sx,sy, ZOrder::UI, 1,1, c )
    end
    
    $win.font.draw("#{@ex},#{@ey}", 0,0, ZOrder::UI)
  end
  
  def tick
    
    @open.sort! { |a,b| a.f <=> b.f }
    
    current = @open.shift
    
    if not current
      puts "Ran out of nodes"
      failed
      return
    end

    if current.x == @ex and current.y == @ey
      # Construct a path
      while current
        @path << [current.x,current.y]
        current = current.parent
      end
      @path.reverse!
      done
      return
    end

    @closed << current
    
    #puts "Working with #{current}"
    
    consider( current.x-1, current.y, current )
    consider( current.x+1, current.y, current )
    consider( current.x, current.y-1, current )
    consider( current.x, current.y+1, current )

  end
  
  
  def consider( x,y, parent, cost = 1 )
    return if $map.outside?(x,y) or $map.solid?(x,y)  # Cannot walk through walls or outside map
    
    # What G should the new/updated node have?
    if not parent
      my_g = 0
    else
      my_g = parent.g + cost
    end
    
    # if (this neighbor is in the closed list and our current g value is lower) {
    #     update the neighbor with the new, lower, g value 
    #     change the neighbor's parent to our current node
    # }
    @closed.each do |n|
      if n.x == x and n.y == y 
        if my_g < n.g
          @closed.delete(n)
          n.g = my_g
          n.parent = parent
          @closed << n
        end
        return
      end
    end
    
    # else if (this neighbor is in the open list and our current g value is lower) {
    #     update the neighbor with the new, lower, g value 
    #     change the neighbor's parent to our current node
    # }
    @open.each do |n|
      if n.x == x and n.y == y
        if my_g < n.g
          @open.delete(n)
          n.g = my_g
          n.parent = parent
          @open << n
        end
        return
      end
    end

    
    # else this neighbor is not in either the open or closed list {
    #     add the neighbor to the open list and set its g value
    n = Node.new( x,y, @ex,@ey, parent )
    n.g = my_g # It costs 10 points to move
    n.calc
    @open << n
  end
  
end



class PathPlanner
  @@work = []
  
  def PathPlanner.find( who, sx,sy, ex,ey, method = :astar )    
   j = nil
   
   # TODO: start caring what method holds...
   j = AStar.new( who, sx,sy, ex,ey )
   
   @@work << j
  end

  def PathPlanner.tick
    @@work.delete_if do |w|
      w.tick
      if w.done?
        if w.failed?
          w.on_failure
        else
          w.on_success
        end
        true
      else
        false
      end
    end
  end

  def PathPlanner.draw( cam, dwarf )
    @@work.each do |w|
      w.draw( cam ) if w.requester == dwarf
    end
  end
  
  
end

