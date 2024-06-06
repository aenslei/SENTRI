# win-inspector Tool
Developing a simple tool to check a workplace device's security posture according to a set of security rules to determine whether it should be allowed to enter a company's intranet.
Will be made using Powershell and references Windows Registry keys and information from publicly available APIs.

Tool will go through 3 different types of checks to determine whether it is secure enough to enter an intranet:

**1**: Network Locality
- Checks a devices geolocation through a devices IP Address by using a publicly available API.

**2**: Security Product
- Checks if a device has any AV, Firewall and VPN products by checking the existence of certain Windows Registry keys.
--> For the simplicity of this tool, I will be focusing on checking for 3 commercial products: Windows Defender, Norton Security and ExpressVPN.

**2**: Operating System
- Checks if a device has the latest Windows patch.
