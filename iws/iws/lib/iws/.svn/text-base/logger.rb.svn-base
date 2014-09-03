class Logger

  def initialize path,tail=nil
    if tail
      @fd = File.new("#{path}.#{tail}","a")
    else
      @fd = File.new("#{path}","a")
    end
  end

  def << info
    @fd.print "#{Time.now}: #{info}\n"
    @fd.flush
  end

  def close
    @fd.close
  end

end
