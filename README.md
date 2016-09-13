# Unfetter fork of mediawiki-vagrant

This is a fork of https://github.com/wikimedia/mediawiki-vagrant/ which provides a downloadable version of The MITRE Corporation's <a href="https://car.mitre.org">Cyber Analytics Repository</a> (CAR) and <a href="https://attack.mitre.org">Adversarial Tactics, Techniques, and Common Knowledge</a> (ATT&CK&trade;) wikis. Along with CARET, the CAR Exploration Tool.
For more information, please see https://mitre.github.io/unfetter

## Install

1. Install Virtualbox 5.0.26 and vagrant 1.8.1
1. Perform all of the instructions for the normal [mediawiki-vagrant](https://github.com/wikimedia/mediawiki-vagrant) installation but perform the <code>git clone</code> with the address of this repository. Do not download the zip file from this repository. It will not provide the needed submodules.
 * Per the mediawiki-vagrant instructions, run ```git submodule update --init --recursive``` followed by the appropriate setup script for your operating system.
 * Run the appropriate setup script for your platform (e.g., ```setup.bat``` or ```setup.sh```).
 * If you receive an error when building the mediawiki-vagrant gem, make sure you're using the version of Vagrant specified in the Gemfile.lock file.
2. After performing an initial ```vagrant up``` enter a ```vagrant roles enable unfetter``` to enable the Unfetter roles, which installs the CAR and ATT&CK wiki content.
3. Enter ```vagrant provision``` to provision the VM according to the Unfetter role
 * We recommend disabling any proxies during setup. We have found that provisioning does not work well when using a proxy.
4. Navigate to http://localhost:8080/ to view a version of CAR. A link to ATT&CK is list on the CAR landing page. CARET is located at http://localhost:8080/caret.

## Adding New Groups, Analytics, and Sensors
The downloadable versions of CAR and ATT&CK are designed to be customizable for users to add new adversary groups (to ATT&CK) or analytics and sensors (to CAR).  

### Adding a New Group to ATT&CK
1. On the navigation bar on the left hand side of the ATT&CK wiki there is a heading for “Groups.”
1. Underneath the “Groups” heading is the option to “Add a Group.”  Navigate to this page.  
1. On the “Create Group” page, you will see text boxes for “Alias” and “Description” as well as drop-down menus and fields for “Techniques” and “Software.”  Complete these fields and hit save to register the entry.
 * <i>Alias</i> refers to the name(s) of the group.
 * <i>Description</i> is a brief summary of the group – such as what campaigns the group is responsible for and information about the attribution of the group.
 * <i>Techniques</i> Used are the ATT&CM techniques used.  The open field may be used to explain how that particular group uses the ATT&CK technique.
 * <i>Software</i> is a field to list the named software used by the group.
 
### Adding a New Analytic to CAR
1. On the navigation bar on the left-hand side of the CAR wiki there is a heading for “Contribute.”
1. Underneath the “Contribute” heading is the option “Analytics.”  Navigate to this page.
1. On the “Create Analytic” page, you will see text boxes for:  Title, Hypothesis, Submission Date, Information Domain, Host/Network Subtypes, Network Protocols (where applicable), Type, Status, Output Description, ATT&CK Detection, Pseudocode, and Unit Tests (where applicable).  Complete these fields and hit save to register the entry. For more information about the CAR Data Model, see “Data Model” under the “Coverage” heading of the navigation bar on the left hand side of the wiki.  
 * <i>Title</i> refers to the name of the analytic.
 * <i>Hypothesis</i> refers to the question, challenge, or adversary behavior the analytic is trying to detect and how the user believes it can be detected.
 * <i>Submission</i> Date refers to when the analytic was created by the user.
 * <i>Information Domain</i> refers to where the analytic<a href="#footnote1" id="footnote1_src"><sup>[1]</sup></a> applies and works to detect the adversary – either at the analytic, host, or network level.
 * <i>Host/Network Subtypes</i> refers to the object in the data model that must be monitored and gathered in order to obtain the data necessary to run the analytic.
 * <i>Network Protocols applies</i> to network analytics and refers to the specific protocol that contains the data (i.e., SMB).
 * <i>Type</i> refers to the types of analytics categorized by the CAR data model (TTP, Attribution, Posture/Hygiene, Situational Awareness, Forensic, Anomaly, Statistical, Investigative, Malware, Event Characterization).
 * <i>Status</i> refers to whether the analytic is actively being used in the system, in which case the status is listed as "active."
 * <i>Output Description</i> refers to the objects, actions, and fields in the data model the analytic detects.  For more information, please see the Data Model page found on the left-hand navigation bar of the wiki.
 * <i>ATT&CK Detection</i> refers to the ATT&CK techniques, tactics, and level of coverage (moderate or complete) of the analytic.  
 * <i>Pseudocode</i> refers to a description of how the analytic might be implemented.
 * <i>Unit Tests</i> refer to a test that can be run to trigger the analytic.

### Adding a New Sensor to CAR
1. On the navigation bar on the left-hand side of the CAR wiki there is a heading for “Contribute.”
1. Underneath the “Contribute” heading is the option “Sensors.”  Navigate to this page.
1. On the “Create Sensor” page you will see options for:  Title, Manufacturer, Release Date, Version, Website, Description, Analytic Coverage, Technique Coverage, and Data Model Coverage.  Complete these fields and checkboxes and hit save to register the entry.
 * <i>Title</i> refers to the name of the sensor.
 * <i>Manufacturer</i> refers to the company producing the sensor.
 * <i>Release Date</i> refers to the Manufacturer’s release date for the sensor.
 * <i>Version</i> refers to the version of the sensor being used.
 * <i>Website</i> refers to the Manufacturer’s website for the sensor.
 * <i>Description</i> refers to what the sensor is, who it is owned by, what it does, what information it collects, and how.
 * <i>Analytic Coverage</i> is the analytics that use information from this sensor to produce results.  Mapping a sensor to an analytic indicates that a sensor can be used in conjunction with an analytic to answer a question about a group’s ATT&CK technique coverage.
 * <i>Technique Coverage</i> is the ATT&CK techniques that a sensor can help identify when used in conjunction with particular analytics.  Coverage is either not present (red), partial (yellow), or complete (green) in the colored boxes of the ATT&CK Matrix.
 * <i>Data Model Coverage</i> refers to the objects, actions, and fields within the Data Model that a sensor collects.  The Data Model, inspired strongly by [CybOX](http://cyboxproject.github.io)&trade;, is an organization of the objects or observables that may be monitored on the host and from the network.  Each object on the host can be identified by two dimensions:  its actions and fields.  When grouped together, the three-tuple of (object, action, field) acts like a coordinate, and describes what properties and state changes of the object can be captured by a sensor.  Compare the Data Model's use in analytics that map to ATT&CK and its use for different sensors.  For example, the “process” object of the Data Model requires fields such as “FQDN” and “Hostname” and must capture actions such as “create” and “terminate.”  Some sensors are static/forensic rather than real-time in nature and do not capture the individual actions of the Data Model; thus, they have incomplete ATT&CK coverage, indicating an inability to use the analytics of CAR to detect an adversary completing a particular ATT&CK technique.

<hr />
<a name="footnote1" href="#footnote1_src">1</a>: Select analytic when an analytic is designed to group other analytics together.

<hr />
ATT&CK is a trademark of The MITRE Corporation.

Copyright 2016 The MITRE Corporation. ALL RIGHTS RESERVED.

