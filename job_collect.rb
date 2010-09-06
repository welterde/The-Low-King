
class JobCollect < Job
  
  def initialize(options = {})
    super(options)
    @work_state = 0
  end
  
  def on_fail
    # Reset
    @work_state = 0
  end
  
  def on_arrival( worker )
    if @work_state == 0 # Arrived at resource
      puts "Arrived at pickup location #{@x},#{@y}"
      res = Entity.get_resource( @x,@y )
      if res.length > 0
        worker.pickup(res[0])
        worker.goto( @tx, @ty )
        @work_state = 1
      else
        puts "WARNING: resource was not found!"
        worker.state = :idle
        fail! true
      end
    else
      # Arrived at stockpile
      worker.drop(@tx,@ty)
      worker.job_done!
    end
    
  end
  
end