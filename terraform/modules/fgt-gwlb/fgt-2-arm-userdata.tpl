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

config system settings
set allow-subnet-overlap enable
end

config system probe-response
set mode http-probe
set port 8008
set http-probe-value OK
end

config system interface
edit port1
set vdom root
set alias 2-arm-public
set mode dhcp
%{ if dedicated_mgmt == "false" }
set allowaccess ping https fgfm
%{ endif }
%{ if dedicated_mgmt == "true" }
set allowaccess ping
%{ endif }
set type physical
set mtu-override enable
set mtu 9001
next
edit port2
set vdom root
set alias 2-arm-private
set mode dhcp
set defaultgw disable
%{ if dedicated_mgmt == "false" }
set allowaccess ping https fgfm probe-response
%{ endif }
%{ if dedicated_mgmt == "true" }
set allowaccess ping
%{ endif }
set allowaccess ping probe-response
set type physical
set mtu-override enable
set mtu 9001
next
%{ if dedicated_mgmt == "true" }
edit port3
set vdom root
set alias dedicated-mgmt
set mode dhcp
set defaultgw enable
set allowaccess ping https fgfm
set vrf 1
set dedicated-to management
set type physical
set mtu-override enable
set mtu 9001
next
%{ endif }
end

config system geneve
edit gwlb1-az1
set interface port2
set type ppp
set remote-ip ${gwlb_ip1}
next
edit gwlb1-az2
set interface port2
set type ppp
set remote-ip ${gwlb_ip2}
next
%{ if gwlb_ip3 != "" }
edit gwlb1-az3
set interface port2
set type ppp
set remote-ip ${gwlb_ip3}
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit gwlb1-az4
set interface port2
set type ppp
set remote-ip ${gwlb_ip4}
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit gwlb1-az5
set interface port2
set type ppp
set remote-ip ${gwlb_ip5}
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit gwlb1-az6
set interface port2
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
edit 0
set dst ${gwlb_ip1}/32
set device port2
set dynamic-gateway enable
set comment 'host route to reach GWLB eni for geneve tunnel in AZ1'
next
edit 0
set dst ${gwlb_ip2}/32
set device port2
set dynamic-gateway enable
set comment 'host route to reach GWLB eni for geneve tunnel in AZ2'
next
%{ if gwlb_ip3 != "" }
edit 0
set dst ${gwlb_ip3}/32
set device port2
set dynamic-gateway enable
set comment 'host route to reach GWLB eni for geneve tunnel in AZ3'
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit 0
set dst ${gwlb_ip4}/32
set device port2
set dynamic-gateway enable
set comment 'host route to reach GWLB eni for geneve tunnel in AZ4'
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit 0
set dst ${gwlb_ip5}/32
set device port2
set dynamic-gateway enable
set comment 'host route to reach GWLB eni for geneve tunnel in AZ5'
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit 0
set dst ${gwlb_ip6}/32
set device port2
set dynamic-gateway enable
set comment 'host route to reach GWLB eni for geneve tunnel in AZ6'
next
%{ endif }
edit 0
set distance 5
set priority 100
set device gwlb1-az1
set comment 'only used for RPF check and not for routing'
next
edit 0
set distance 5
set priority 100
set device gwlb1-az2
set comment 'only used for RPF check and not for routing'
next
%{ if gwlb_ip3 != "" }
edit 0
set distance 5
set priority 100
set device gwlb1-az3
set comment 'only used for RPF check and not for routing'
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit 0
set distance 5
set priority 100
set device gwlb1-az4
set comment 'only used for RPF check and not for routing'
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit 0
set distance 5
set priority 100
set device gwlb1-az5
set comment 'only used for RPF check and not for routing'
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit 0
set distance 5
set priority 100
set device gwlb1-az6
set comment 'only used for RPF check and not for routing'
next
%{ endif }
end

config router policy
edit 1
set input-device gwlb1-az1
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az1
set comment '2-arm mode hairpins traffic to RFC1918 CIDR, otherwise skips policy route for public CIDRs'
next
edit 2
set input-device gwlb1-az2
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az2
set comment '2-arm mode hairpins traffic to RFC1918 CIDR, otherwise skips policy route for public CIDRs'
next
%{ if gwlb_ip3 != "" }
edit 3
set input-device gwlb1-az3
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az3
set comment '2-arm mode hairpins traffic to RFC1918 CIDR, otherwise skips policy route for public CIDRs'
next
%{ endif }
%{ if gwlb_ip4 != "" }
edit 4
set input-device gwlb1-az4
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az4
set comment '2-arm mode hairpins traffic to RFC1918 CIDR, otherwise skips policy route for public CIDRs'
next
%{ endif }
%{ if gwlb_ip5 != "" }
edit 5
set input-device gwlb1-az5
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az5
set comment '2-arm mode hairpins traffic to RFC1918 CIDR, otherwise skips policy route for public CIDRs'
next
%{ endif }
%{ if gwlb_ip6 != "" }
edit 6
set input-device gwlb1-az6
set dst "10.0.0.0/255.0.0.0" "172.16.0.0/255.240.0.0" "192.168.0.0/255.255.0.0"
set output-device gwlb1-az6
set comment '2-arm mode hairpins traffic to RFC1918 CIDR, otherwise skips policy route for public CIDRs'
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
set name "2-arm-egress"
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
set name "2-arm-hairpin"
set srcintf "gwlb1-tunnels"
set dstintf "gwlb1-tunnels"
set srcaddr "all"
set dstaddr "all"
set action accept
set schedule "always"
set service "ALL"
set logtraffic all
next
end

config system sdn-connector
edit aws-instance-role
set status enable
set type aws
set use-metadata-iam enable
set alt-resource-ip enable
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