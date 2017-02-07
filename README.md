Okta AWS CLI Assume Role Script
===============================

## Summary
This script will setup and run the Okta AWS CLI Assume Role Tool

https://github.com/oktadeveloper/okta-aws-cli-assume-role

## Quickstart
Run the following to install, configure, and run this tool. You might be asked for your password as this script attempts to install itself into /usr/local/bin.

```
~ $ curl -L https://raw.githubusercontent.com/stvleung/okta-aws-cli-assume-role.sh/master/okta-aws-cli-assume-role.sh | sh
```

If you don't have curl but wget, replace `curl -L` with `wget -O -`.

## Usage

```
~ $ okta-aws-cli-assume-role
Username: [myuser]
Password: [mypass]
...
```

## Prerequisites for script
- sudo
- git
- java

