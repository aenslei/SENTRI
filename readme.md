# SENTRI: Securing Entry to Network Through Review and Inspection
A Network Access Control [NAC] tool to check a workplace client's security posture according to a set security posture baseline to determine whether it should be allowed to enter a company's internal network.
Developed using only Powershell and utilises the Windows Registry and information from publicly available APIs and websites.

SENTRI will go through 3 different types of checks to determine whether its client is secure enough to enter an internal network:

**1**: Network Locality
- Checks the client's geolocation through its IP Address by using a publicly available API. </br>
--> Cross-references country of origin to the UN Sanctions List to determine if the connection request may be risky to accept.

**2**: Security Product
- Checks if the client has certain AV/Firewall/VPN products by checking the existence and properties of certain Windows Registry keys. </br>
--> For the simplicity (and time constraint during development) of this tool, I will be focusing on checking for 3 commercial products: Windows Defender (has issues), Norton Security and ExpressVPN. </br>
--> Uses web scraping to extract the latest versions.

**3**: Operating System
- Checks if a device has the latest Windows patch by extracting the client's current Windows Build Version.
--> Uses web scraping to extract the latest versions.

The final variable, connectToIntranet, will be either Pass/Fail. If even 1 of the checks fail, the host is deemed to be not in compliance with the security posture and thus will be unable to be connected to the internal network.

*This project was made for my GovTech Singapore Girls in Tech Mentorship Program! Thank you to my mentor, Pei Chern, for all her guidance. ◕◡◕*
