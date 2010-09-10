
require 'rubygems'
require 'gosu'

$LOAD_PATH << File.join(File.dirname(__FILE__) )

require 'ext'
require 'misc'
require 'map'
require 'camera'
require 'entity'
require 'dwarf'
require 'pathfinding'
require 'jobs'
require 'job_mine'
require 'job_collect'
require 'resource'
require 'res_rock'

class Game < Gosu::Window
  
  attr_reader :font
  
  def initialize
    super 640,480, false
    $win = self
    
    @font = Gosu::Font.new( self, Gosu::default_font_name, 6 )
    
    
    t = Time.now.to_f
    puts "Creating map..."
    @map = Map.new
    $map = @map
    @map.set_tile( 15,10, [ROCK,DIRT] )
    puts "Done in %.1f seconds." % [Time.now.to_f - t]
    
    @cam = Camera.new
    
    
    d1 = Dwarf.new
    d1.place( 8,5 )
    d2 = Dwarf.new
    d2.place( 8,6 )
    
    @entity_timer = Time.now.to_f + ENTITY_TIME_STEP
    @selected_dwarf = nil
    
    @paused = false
  end
  
  
  def button_down( id )
    sx = (($win.mouse_x / 4).to_i)
    sy = (($win.mouse_y / 4).to_i)
    mx = (sx / 8)+@cam.x
    my = (sy / 8)+@cam.y
      
    if id == Gosu::MsLeft
      #@d1.goto( @map, mx,my )

      if @map.solid?( mx,my )
        if @map.selected?(mx,my)
          @map.unselect(mx,my)
        else
          JobMine.new( :x => mx, :y => my )
          @map.select( mx,my )
        end
      else
        #Get entity that was clicked
        @selected_dwarf = nil
        entities = Entity.pick( mx,my )
        if entities.length > 0
          picked = entities[0]
          if picked.class == Dwarf
            # Select dwarf
            @selected_dwarf = picked
            puts "Selected #{@selected_dwarf}"
          end
        end
      end
    
    end
      
    if id == Gosu::KbSpace
      @paused = !@paused
    end
      
    if id == Gosu::KbA
      @map.set_tile( mx,my, [ROCK,ROCK] )
    end

    if id == Gosu::KbZ
      t = @map.get_tile( mx,my )
      t[0] = AIR
      @map.set_tile( mx,my, t )
    end
    
    
    if id == Gosu::KbF1
      @map.save("test.map")
    end

    if id == Gosu::KbF2
      ok,errmsg = @map.load("test.map")
      puts errmsg if not ok
    end


    @cam.move(1,0) if id == Gosu::KbRight
    @cam.move(-1,0) if id == Gosu::KbLeft
    @cam.move(0,1) if id == Gosu::KbDown
    @cam.move(0,-1) if id == Gosu::KbUp

  end
  
  def needs_cursor?
    true
  end
  
  
  def update
    tnf = Time.now.to_f
    if not @paused
      PathPlanner.tick
      
      if @entity_timer <= tnf
        @entity_timer = tnf+ENTITY_TIME_STEP
        Entity.tick_all
      end
    end
  end
  
  
  def draw
    scale 4 do
      @map.draw( @cam.x, @cam.y )
      Entity.draw_all @cam 
      PathPlanner.draw @cam, @selected_dwarf
      
      @font.draw("PAUSED", 60,0, ZOrder::UI ) if @paused
      
      @font.draw("Jobs: #{Job.count}", 0,104, ZOrder::UI)

    end
  end
  
end


Game.new.show