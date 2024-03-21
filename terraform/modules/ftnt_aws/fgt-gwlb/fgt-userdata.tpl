Content-Type: multipart/mixed; boundary="==Boundary=="
MIME-Version: 1.0

--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
set hostname ${hostname}
set admintimeout 60
end

config system interface
edit port1
set vdom root
set alias public
set mode dhcp
set allowaccess ping https ssh http fgfm
set type physical
set mtu-override enable
set mtu 9001
next
edit port2
set alias private
set mode dhcp
set defaultgw disable
set allowaccess ping https ssh fgfm
set mtu-override enable
set mtu 9001
next
end

config system geneve
edit gwlb1-az1
set interface port1
set type ppp
set remote-ip ${gwlb_ip1}
next
edit gwlb1-az2
set interface port1
set type ppp
set remote-ip ${gwlb_ip2}
next
%{ if gwlb_ip3 != "" }
edit gwlb1-az3
set interface port1
set type ppp
set remote-ip ${gwlb_ip3}
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit gwlb1-az4
set interface port1
set type ppp
set remote-ip ${gwlb_ip4}
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit gwlb1-az5
set interface port1
set type ppp
set remote-ip ${gwlb_ip5}
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit gwlb1-az6
set interface port1
set type ppp
set remote-ip ${gwlb_ip6}
next
%{ endif }
end

config system zone
edit gwlb1-tunnels
%{ if azs == "2" }
set interface "gwlb1-az1" "gwlb1-az2"
%{ endif }
%{ if azs == "3" }
set interface "gwlb1-az1" "gwlb1-az2" "gwlb1-az3"
%{ endif }
%{ if azs == "4" }
set interface "gwlb1-az1" "gwlb1-az2" "gwlb1-az3" "gwlb1-az4"
%{ endif }
%{ if azs == "5" }
set interface "gwlb1-az1" "gwlb1-az2" "gwlb1-az3" "gwlb1-az4" "gwlb1-az5"
%{ endif }
%{ if azs == "6" }
set interface "gwlb1-az1" "gwlb1-az2" "gwlb1-az3" "gwlb1-az4" "gwlb1-az5" "gwlb1-az6"
%{ endif }
next
end

config router static
edit 1
set distance 5
set priority 100
set device gwlb1-az1
next
edit 2
set distance 5
set priority 100
set device gwlb1-az2
next
%{ if gwlb_ip3 != "" }
edit 3
set distance 5
set priority 100
set device gwlb1-az3
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit 4
set distance 5
set priority 100
set device gwlb1-az4
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit 5
set distance 5
set priority 100
set device gwlb1-az5
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit 6
set distance 5
set priority 100
set device gwlb1-az6
next
%{ endif }
end

config router policy
edit 1
set input-device gwlb1-az1
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az1
next
edit 2
set input-device gwlb1-az2
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az2
next
%{ if gwlb_ip3 != "" }
edit 3
set input-device gwlb1-az3
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az3
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit 4
set input-device gwlb1-az4
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az4
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit 5
set input-device gwlb1-az5
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az5
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit 6
set input-device gwlb1-az6
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az6
next
%{ endif }
end

config firewall address
edit "10.0.0.0/8"
set subnet 10.0.0.0 255.0.0.0
next
edit "172.16.0.0/12"
set subnet 172.16.0.0 255.240.0.0
next
edit "192.168.0.0/16"
set subnet 192.168.0.0 255.255.0.0
next
end

config firewall addrgrp
edit "rfc-1918-subnets"
set member "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
next
end

config firewall policy
edit 1
set name "egress"
set srcintf "gwlb1-tunnels"
set dstintf "port1"
set srcaddr "rfc-1918-subnets"
set dstaddr "all"
set action accept
set schedule "always"
set service "ALL"
set logtraffic all
set nat enable
next
edit 2
set name "ingress"
set srcintf "gwlb1-tunnels"
set dstintf "gwlb1-tunnels"
set srcaddr "all"
set dstaddr "rfc-1918-subnets"
set action accept
set schedule "always"
set service "ALL"
set logtraffic all
next
edit 3
set name "east-west"
set srcintf "gwlb1-tunnels"
set dstintf "gwlb1-tunnels"
set srcaddr "rfc-1918-subnets"
set dstaddr "rfc-1918-subnets"
set action accept
set schedule "always"
set service "ALL"
set logtraffic all
next
end

%{ if license_type == "byol" }
--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${file(license_file)}
%{ endif }
%{ if license_type == "flex" }
--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN: ${license_token}
%{ endif }
--==Boundary==--