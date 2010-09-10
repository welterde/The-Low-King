


class Job
  
  @@list = []
  
  def Job.fetch
    @@list.each_with_index do |j,i|
      taken = yield j
      if taken
        @@list.delete j
        puts "Selected job #{i}: #{j}"
        return j
      end
    end
    
    return []
  end
  
  def Job.add( j )
    @@list << j
    @@list.sort! { |a,b| b.priority <=> a.priority }
  end
  
  def Job.failed( j )
    j.priority -= 0.01
    Job.add( j )
  end
  
  def Job.count
    @@list.length
  end
  
  attr_reader :x, :y, :on_arrival
  attr_accessor :priority
  
  def initialize( data = {} )
  
    @priority = data[:priority] || POrder::LOW
    
    @x = data[:x]
    @y = data[:y]
    @tx = data[:tx]
    @ty = data[:ty]
    #@on_arrival = data[:on_arrival]

    Job.add( self )
  end
  
  def fail!( destroy_job = false)
    on_fail
    Job.failed(self) unless destroy_job
  end
  
  def on_fail
    
  end
  
  
  def on_arrival( worker )
    
  end
  
  
  def start( worker )
    puts "Starting job #{self.class}, Finding suitable spot for dwarf"
    wx,wy = nil,nil
    if not $map.solid?( @x,@y )
      wx,wy = @x,@y
    else
      wx,wy = $map.find_closest_spot( @x, @y, worker.x,worker.y )    
    end
    
    if wx
      worker.goto( wx, wy )
    else
      # Dwarf cannot move to this square, fail this job and pick another
      # The dwarf will remember this jobs for a while, so it wont get picked again
      worker.failed_jobs << [self, Time.now+rand(60) ]
      fail!
    end
  end
  
end

