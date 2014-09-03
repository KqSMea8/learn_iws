require "iws"
require "rack/test"

home = File.join(File.dirname(__FILE__),'..')
$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]

os_str = File.new("/etc/redhat-release").readline
case os_str
when /CentOS/ 
  $os = :centos
when /Red Hat Enterprise/
  $os = :redhat
end

$debug = true
