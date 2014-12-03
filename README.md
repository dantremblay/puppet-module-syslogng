# syslogng module #
===

Module to manage syslog-ng. Handles both local and remote logging.

Inspired by [ghoneycutt/rsyslog](https://github.com/ghoneycutt/puppet-module-rsyslog/)

===

# Compatibility #

This module has been tested to work on the following systems with Puppet v3.x and Ruby versions 1.8.7, 1.9.3, and 2.0.0.

 * Suse 10

===

# Parameters #

package
-------
Name of the syslog-ng package.

- *Default*: 'syslog-ng'

package_ensure
--------------
What state the package should be in. Valid values are 'present', 'absent', 'purged', 'held' and 'latest'.

- *Default*: 'present'

package_provider
----------------
Change package provider.

- *Default*: undef

logrotate_present
-----------------
Enable logrotate.

- *Default*: 'USE_DEFAULTS'

logrotate_d_config_path
-----------------------
Path of the logrotate config file.

- *Default*: 'USE_DEFAULTS'

logrotate_d_config_owner
------------------------
Owner of the logrotate config file.

- *Default*: 'root'

logrotate_d_config_group
------------------------
Group of the logrotate config file.

- *Default*: 'root'

logrotate_d_config_mode
-----------------------
Mode of the logrotate config file.

- *Default*: '0644'

logrotate_d_config_file
-----------------------
Path of the logrotate config file.

- *Default*: 'USE_DEFAULTS'

logrotate_syslog_files
----------------------
Array of files which should be log rotated by /etc/logrotate.d/syslog ($logrotate_d_config_path).

- *Default*:  'USE_DEFAULTS'

config_path
-----------
Path of the syslog-ng config file.

- *Default*: 'USE_DEFAULTS'

config_owner
------------
Owner of the syslog-ng config file.

- *Default*: 'root'

config_group
------------
Group of the syslog-ng config file.

- *Default*: 'root'

config_mode
-----------
Mode of the syslog-ng config file.

- *Default*: '0644'

config_file_erb
---------------
Template of the syslog-ng config file.

- *Default*: 'USE_DEFAULTS'

sysconfig_path
--------------
Path of the syslog-ng sysconfig config file.

- *Default*: 'USE_DEFAULTS'

sysconfig_owner
---------------
Owner of the syslog-ng sysconfig config file.

- *Default*: 'root'

sysconfig_group
---------------
Group of the syslog-ng sysconfig config file.

- *Default*: 'root'

sysconfig_mode
--------------
Mode of the syslog-ng sysconfig config file.

- *Default*: '0644'

service_name
------------
Name of the syslog-ng service.

- *Default*: 'USE_DEFAULTS'

service_ensure
--------------
Whether a service should be running. Valid values are 'stopped' and 'running'.

- *Default*: 'running'

service_enable
-------------
Whether a service should be enabled to start at boot. Valid values are 'true', 'false', 'manual'.

- *Default*: true

remote_logging
----------------------
Whether to send logs remotely to a centralized logging service.

- *Default*: false

log_servers
-----------
Server to send logs to if remote_logging is true.

<pre>
syslogng::log_servers:
  'log1':
    transport_protocol: 'udp'
    host: 'log1.example.com'
    port: 514
</pre>

- *Default*: undef
