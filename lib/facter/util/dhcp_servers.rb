module Facter::Util::DHCPServers
  def self.gateway_device
    Facter::Core::Execution.exec("route -n").scan(/^0\.0\.0\.0.*?(\S+)$/).flatten.first
  end

  def self.devices
    if Facter::Core::Execution.which('nmcli')
      Facter::Core::Execution.exec("nmcli d").split("\n").select {|d| d =~ /\sconnected/i }.collect{ |line| line.split[0] }
    else
      []
    end
  end

  def self.device_dhcp_server(device)
    if Facter::Core::Execution.which('nmcli')
      if self.nmcli_version and self.nmcli_version >= 990
        Facter::Core::Execution.exec("nmcli d show #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
      else
        Facter::Core::Execution.exec("nmcli d list iface #{device}").scan(/dhcp_server_identifier.*?(\d+\.\d+\.\d+\.\d+)$/).flatten.first
      end
    end
  end

  def self.nmcli_version
    if version = Facter::Core::Execution.exec("nmcli --version").scan(/version\s([\d\.]+)/).flatten.first
      version.gsub(/\./,'').to_i
    end
  end
end