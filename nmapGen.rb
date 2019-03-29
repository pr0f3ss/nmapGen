require "optparse"
require "nmap/program"
require "nmap/xml"

class NMapHandler
  @osFingerprint = false
  @target = ""
  @ports = ""

  def initialize(osFingerprint, target, ports)
    @osFingerprint = osFingerprint
    @target = target
    ports.kind_of?(Array) ? @ports = ports : (raise ArgumentError, "Port list must be specified as array. [80, 8080] as an example")
  end

  def scan
    Nmap::Program.scan do |nmap|
      nmap.syn_scan = true
      nmap.service_scan = true
      nmap.os_fingerprint = @osFingerprint
      nmap.xml = 'scan.xml'
      nmap.verbose = true

      nmap.ports = @ports == -1 ? [20,21,22,23,25,80,110,443,512,522,8080,1080] : @ports
      nmap.targets = @target
    end
  end

  #writes scan information in fileName
  def writeInformation(fileName)
    Nmap::XML.new('scan.xml') do |xml|
      xml.each_host do |host|
        File.open(fileName, "a") do |line|
          if(host.status.to_s == "down")
            line.puts "[#{host.ip}] is down\n\n"
            next
          end
          line.puts "[#{host.ip}]"
          host.each_port do |port|
            line.puts "  #{port.number}/#{port.protocol}\t#{port.state}\t#{port.service}"
          end
          if(@osFingerprint)
            line.puts "#{host.os.matches[0]}"
          end
          line.puts "\n"
        end
      end
    end
  end
end
#===============================FUNCS===========================================

def readPorts(options, line)
  fileName = options[:portList]
  portList = []
  File.open(fileName).each do |line|
    portList.append(line)
  end

  case(options[:rFile])
  when nil
    return NMapHandler.new(options[:os] != nil ? true : false, options[:target], portList)
  else
    return NMapHandler.new(options[:os] != nil ? true : false, line.delete("\n"), portList)
    return
  end

end



#================================MAIN===========================================

options = {}

OptionParser.new do |opt|
  opt.banner = "Usage: ruby nmapGen.rb [options]"

  opt.on("-o", "--os", "set flag to scan OS") do |os|
    options[:os] = os
  end

  opt.on("-t", "--target TARGET", "scan target IP address") do |t|
    options[:target] = t
  end

  opt.on("-w", "--writeFile NAME", "write output to file specified by NAME") do |w|
    options[:wFile] = w
  end

  opt.on("-r", "--readFile NAME", "read input target from file specified by NAME line per line") do |r|
    options[:rFile] = r
  end

  opt.on("-p", "--ports PORT", "searches specified ports given by comma separated input") do |p|
    options[:ports] = p.split(",")
  end

  opt.on("-l", "--listports FILE", "use file to specify portlist, line per line. -l has higher presedence than the -p paramater") do |l|
    options[:portList] = l
  end

  opt.on_tail("-h" , "--help", "prints this help menu") do
    puts opt
    exit
  end

end.parse!

#===============================================================================

if(options[:rFile] == nil && options[:target] == nil)
  raise ArgumentError, "No target addresses specified. See -h for help."

elsif(options[:rFile] == nil && options[:target] != nil)
  case(options[:portList])
  when nil
    newScan = NMapHandler.new(options[:os] != nil ? true : false, options[:target], options[:ports] != nil ? options[:ports] : -1)
  else
    newScan = readPorts(options, nil)
  end

else

  File.open(options[:rFile]).each do |line|
    case(options[:portList])
    when nil
      newScan = NMapHandler.new(options[:os] != nil ? true : false, line.delete("\n"), options[:ports] != nil ? options[:ports] : -1)
    else
      newScan = readPorts(options, line)
    end

    newScan.scan
    options[:wFile] != nil ? newScan.writeInformation(options[:wFile]) : nil
    puts "\n"
  end

  if(options[:target] != nil)
    case(options[:portList])
      when nil
        newScan = NMapHandler.new(options[:os] != nil ? true : false, options[:target], options[:ports] != nil ? options[:ports] : -1)
      else
        newScan = readPorts(options, nil)
    end
    newScan.scan
    options[:wFile] != nil ? newScan.writeInformation(options[:wFile]) : nil
    puts "\n"
  end
  exit
end

newScan.scan
options[:wFile] != nil ? newScan.writeInformation(options[:wFile]) : exit
