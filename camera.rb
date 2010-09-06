

class Camera
  
  attr_reader :x, :y
  
  def initialize( sx=0, sy=0 )
    @x = sx
    @y = sy
  end
  
  def move( xo,yo )
    @x += xo
    @y += yo
    
  end
  
end