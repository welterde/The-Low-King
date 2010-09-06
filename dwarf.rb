

class Dwarf < Entity

  attr_accessor :state, :failed_jobs

  def initialize( options = {} )
    super
    @zorder = ZOrder::ACTOR
    @tile = 1
    @path = []
    @state = :idle
    @carrying = nil
    @job = nil
    @failed_jobs = []
  end

  def goto( tx,ty )
    return unless tx
    PathPlanner.find( self, @x,@y, tx,ty )
    @state = :planning_path
  end
  
  def pickup( obj )
    @carrying = obj
    obj.on_pickup( self )
  end
  
  def drop( tx,ty )
    @carrying.place(tx,ty)
    @carrying.on_drop( self )
    @carrying = nil
  end
  
  def job_done!
    @state = :idle
    @job = nil
  end

  def on_telegram( msg, data=nil )

    if msg == :path_found
      @path = data
      @state = :follow_path
    elsif msg == :no_path
      puts "Dwarf cannot find path to #{data[:to].join(',')}"
      if @job
        # Got a job dwarf cannot complete. 
        Job.failed( @job )
        @job = nil
      end
      @state = :idle
    else
      puts "Dwarf says WTF? #{msg}"
    end

  end

  def tick
    case @state
    when :idle
      wx = nil
      wy = nil
      
      # Loop through all available jobs until 
      @job = Job.fetch do |j|
        ret = true # Accept this job unless something below prevents this
        
        # TODO: return false if dwarf cannot do this job for whatever reason

        # Check with bad job memories
        @failed_jobs.delete_if { |jm| Time.now >= jm[1] } # Forget memories that are too old
        @failed_jobs.each do |jm|
          ret = false if jm[0] == j
        end
        
        ret
      end
      
      @job = @job[0] if @job.class == Array
      if @job
        puts "Dwarf got new job! #{@job.class}"
        #goto( wx, wy )
        @job.start( self )
      end

    when :follow_path
      ns = @path.shift
      if ns
        @x = ns[0]
        @y = ns[1]
        if @path.length == 0
          @path = nil
          @state = :idle
          puts "Done following path"
          if @job
            @job.on_arrival( self )
          end
        end
      else
        if @job
          @job.on_arrival(self)
        else
          puts "Ran out of path, and had no job."
          @state = :idle
        end
      end
      
    when :mine
      # TODO: make sure we're near the target
      # TODO: mining takes time

      $map.mine( @job.x, @job.y, self )
      
      @state = :idle

    end # case



  end # tick
  
  
  def draw( cam )
    super cam
    sx = (@x-cam.x) * 8
    sy = (@y-cam.y) * 8
        
    if @state == :planning_path
      $win.font.draw("?", sx,sy, ZOrder::UI)
    end
    
  end

end