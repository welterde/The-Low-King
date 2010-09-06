


class Resource < Entity

  def on_pickup( worker )
    @hidden = true
  end
  
  def on_drop( worker )
    @hidden = false
  end
  
end