
class JobMine < Job
  
  def initialize( options = {} )
    options[:priority] ||= POrder::MEDIUM
    super(options)
  end
  
  def on_arrival( worker )
    $map.mine(@x,@y, worker)
    worker.job_done!
    puts "Dwarf mined."
  end
  
end