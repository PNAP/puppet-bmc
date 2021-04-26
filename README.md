<h1 align="center">
  <br>
  <a href="https://phoenixnap.com/bare-metal-cloud"><img src="https://user-images.githubusercontent.com/78744488/109779287-16da8600-7c06-11eb-81a1-97bf44983d33.png" alt="phoenixnap Bare Metal Cloud" width="300"></a>
  <br>
  BMC Puppet Module
  <br>
</h1>

<p align="center">
BMC Puppet Module for provisioning and managing <a href="https://phoenixnap.com/bare-metal-cloud">Bare Metal Cloud</a> resources.
</p>

<p align="center">
  <a href="https://phoenixnap.com/bare-metal-cloud">Bare Metal Cloud</a> •
  <a href="https://developers.phoenixnap.com/">Developers Portal</a> •
  <a href="http://phoenixnap.com/kb">Knowledge Base</a> •
  <a href="https://developers.phoenixnap.com/support">Support</a>
</p>

## Requirements

- [Bare Metal Cloud](https://bmc.phoenixnap.com) account
- Ruby
- BMC Ruby SDK

## Creating a Bare Metal Cloud account

1. Go to the [Bare Metal Cloud signup page](https://support.phoenixnap.com/wap-jpost3/bmcSignup).
2. Follow the prompts to set up your account.
3. Use your credentials to [log in to Bare Metal Cloud portal](https://bmc.phoenixnap.com).

:arrow_forward: **Video tutorial:** [How to Create a Bare Metal Cloud Account](https://www.youtube.com/watch?v=RLRQOisEB-k)
<br>

:arrow_forward: **Video tutorial:** [Introduction to Bare Metal Cloud](https://www.youtube.com/watch?v=8TLsqgLDMN4)

## Before installing

Make sure you have installed the BMC Ruby SDK

```sh
/opt/puppetlabs/puppet/bin/gem install bmc-sdk
```

## Installing the module

The module is available to install through Puppet Forge:

```sh
puppet module install phoenixnap-bmc
```

## Authentication

You need to create a configuration file called `config` and save it in the user home directory. This file is used to authenticate access to your Bare Metal Cloud resources.

In your home directory, create a directory `.pnap` and a `config` file inside it. The file needs to contain only two lines of code:

```yml
    client_id: <enter your client id>
    client_secret: <enter your client secret>
```

To get the values for the clientId and clientSecret, follow these steps:

1. [Log in to the Bare Metal Cloud portal](https://bmc.phoenixnap.com).
2. On the left side menu, click on API Credentials.
3. Click the Create Credentials button.
4. Fill in the Name and Description fields, select the permissions scope and click Create.
5. In the table, click on Actions and select View Credentials from the dropdown.
6. Copy the values from the Client ID and Client Secret fields into your `config` file.

___

## Module Usage

### Creating Bare Metal Instances

The minimal setup for an insntace is

```puppet
pnap_server { 'puppet':
  ensure   => present,
  os       => 'ubuntu/bionic',
  type     => 's1.c1.medium',
  location => 'PHX',
  ssh_keys => [file('path/to/public-key')]
}
```

Applying a Puppet manifest which contains the snippet above will create a BMC server instance named `puppet` in the `PHX` data center using the `ubuntu/bionic` image with size `s1.c1.medium` and will use a ssh key from your home directory as the default ssh key.

Keep in mind that if you already have a default ssh key on your account, you don't have to setup ssh keys on the new instance, the default one will automatically be installed so the `ssh_keys/ssh_key_ids` param can be removed or replaced with `install_default_ssh_keys` and set to `true` (this is a default setting).

### Listing Bare Metal Instances

This module supports listing instances via

``` shell
puppet resource pnap_server
```

or you can display a single instance using

```shell
puppet resource pnap_server <name of instance>
```

### Creating SSH Keys

The minimal setup for an SSH Key is

```puppet
pnap_ssh_key { 'puppet':
  ensure  => present,
  default => false,
  key     => file('/path/to/public-key')
}
```

Applying a Puppet manifest which contains the snippet above will create a BMC SSH Key named `puppet` with default set to `false`.

### Listing SSH Keys

This module supports listing SSH Keys via

``` shell
puppet resource pnap_ssh_key
```

or you can display a single instance using

```shell
puppet resource pnap_server <name of ssh key>
```

## Destroying Resources

To destroy any resource just set the ensure to `absent`

```puppet
pnap_server { 'puppet':
  ensure => absent
}
```
___

## Resource Parameters

### Server

### `ensure` (required)

Valid values are:

`present, absent, poweredon, poweredoff, shutdown, rebooting, resetting`

Read-only values are:

`error, creating`

*present*: It will create or power on a server instance if it exists.

*absent*: It will delete a server instance if it exists.

*poweredon*: It will power on a server instance if it exists.

*poweredoff*: It will power off a server instance if it exists.

*shutdown*: It will shut down a server instance if it exists.

*rebooting*: It will reboot a server instance if it exists.

*resetting*: It will reset a server instance if it exists.

*error* (read-only): Will show if there is an error starting up or provisioning the server instance.

*creating* (read-only): Will show while the current status of the instance is creating

### `id` (read-only property)

The unique identifier of the server.

### `description`

The description of the server.

### `os` (required)

The server's OS ID. This property is read-only once instance is created.

### `type` (required)

Server type ID. This property is read-only once instance is created.

### `location` (required)

Server Location ID. This property is read-only once instance is created.

### `cpu` (read-only property)

A description of the machine CPU.

### `ram` (read-only property)

A description of the machine RAM.

### `storage` (read-only property)

A description of the machine storage.

### `install_default_ssh_keys`

Whether or not to install ssh keys marked as default in addition to any ssh keys specified in this request.

**This property defaults to `false` if not specified otherwise.**

### `ssh_key_ids`

A list of SSH Key IDs that will be installed on the Linux server in addition to any ssh keys specified in this request.

### `ssh_keys`

A list of SSH Keys that will be installed on the Linux server.

### `private_ip_addresses` (read-only property)

Private IP Addresses assigned to server.

### `public_ip_addresses` (read-only property)

Public IP Addresses assigned to server.

### `reservation_id`

Server reservation ID.

### `pricing_model`

Server pricing model.

Valid values are:

`HOURLY, ONE_MONTH_RESERVATION, TWELVE_MONTHS_RESERVATION, TWENTY_FOUR_MONTHS_RESERVATION, THIRTY_SIX_MONTHS_RESERVATION`

### `password` (read-only property)

Password set for user Admin on Windows server which will only be returned in response to provisioning a server

### `network_type`

The type of network configuration for the server.

Valid values are:

`PUBLIC_AND_PRIVATE, PRIVATE_ONLY`

**This property defaults to `PUBLIC_AND_PRIVATE` if not specified otherwise.**

___

### SSH Key

### `ensure` (required)

Valid values are:

`present, absent`

*present*: It will store a SSH key on your PNAP Account.

*absent*: It will delete a SSH key from your PNAP Account.

### `id` (read-only property)

The ID of the SSH key.

### `default`

Is the default SSH key?

Valid values are:

`true, false`

**This property defaults to `false` if not specified otherwise.**

### `key`

SSH Key value.

### `fingerprint` (read-only property)

SSH Key auto-generated SHA-256 fingerprint.

### `created_on` (read-only property)

'Date and time of creation.

### `last_updated_on` (read-only property)

Date and time of last update.

___

## Running Bolt Tasks

TBD

___

## Bare Metal Cloud community

Become part of the Bare Metal Cloud community to get updates on new features, help us improve the platform, and engage with developers and other users.

- Follow [@phoenixNAP on Twitter](https://twitter.com/phoenixnap)
- Join the [official Slack channel](https://phoenixnap.slack.com)
- Sign up for our [Developers Monthly newsletter](https://phoenixnap.com/developers-monthly-newsletter)

### Resources

- [Product page](https://phoenixnap.com/bare-metal-cloud)
- [Instance pricing](https://phoenixnap.com/bare-metal-cloud/instances)
- [YouTube tutorials](https://www.youtube.com/watch?v=8TLsqgLDMN4&list=PLWcrQnFWd54WwkHM0oPpR1BrAhxlsy1Rc&ab_channel=PhoenixNAPGlobalITServices)
- [Developers Portal](https://developers.phoenixnap.com)
- [Knowledge Base](https://phoenixnap.com/kb)
- [Blog](https:/phoenixnap.com/blog)

### Documentation

- [API documentation](https://developers.phoenixnap.com/docs/bmc/1/overview)

### Contact phoenixNAP

Get in touch with us if you have questions or need help with Bare Metal Cloud.

<p align="left">
  <a href="https://twitter.com/phoenixNAP">Twitter</a> •
  <a href="https://www.facebook.com/phoenixnap">Facebook</a> •
  <a href="https://www.linkedin.com/company/phoenix-nap">LinkedIn</a> •
  <a href="https://www.instagram.com/phoenixnap">Instagram</a> •
  <a href="https://www.youtube.com/user/PhoenixNAPdatacenter">YouTube</a> •
  <a href="https://developers.phoenixnap.com/support">Email</a> 
</p>

<p align="center">
  <br>
  <a href="https://phoenixnap.com/bare-metal-cloud"><img src="https://user-images.githubusercontent.com/78744488/109779474-47222480-7c06-11eb-8ed6-91e28af3a79c.jpg" alt="phoenixnap Bare Metal Cloud"></a>
</p>