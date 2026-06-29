# netrun_types.gd
extends Node

## Globally accessible types and namespaces for the Neon Netrun gameplay module.

enum SyscallType {
	CHMOD_SPEED_BOOST,  # sudo chmod +x (Trojan speed + firewall immunity)
	PING_DDoS_DETONATE,  # ping -f (DDoS instant detonation -> EMP)
	TRIGGER_PAYLOAD     # logic bomb manual detonation
}

enum PortType {
	PORT_80,   # HTTP
	PORT_443,  # HTTPS
	PORT_22    # SSH
}
