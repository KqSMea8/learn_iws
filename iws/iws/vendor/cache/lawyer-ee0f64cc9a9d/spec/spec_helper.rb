home = File.join(File.dirname(__FILE__),'..')
$LOAD_PATH.unshift(File.join(home,'lib'))

require 'lawyer'

def mkfile doc
  filename = "/tmp/lawyer_spec_#{rand(9999999)}"
  fd = File.new(filename,"w")
  fd.puts doc
  fd.close
  filename
end

def res_path
  home = File.join(File.dirname(__FILE__),'..')
  File.join(home,"spec/res")
end
