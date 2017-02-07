#!/bin/sh

# Summary
# This script will setup and run the Okta AWS CLI Assume Role Tool
#
# https://github.com/oktadeveloper/okta-aws-cli-assume-role
#
# Quickstart
# Run the following to install, configure, and run this tool. You
# might be asked for your password as this script attempts to install itself
# into /usr/local/bin.
#
#   ~ $ curl -L https://raw.githubusercontent.com/stvleung/okta-aws-cli-assume-role.sh/master/okta-aws-cli-assume-role.sh | sh
#
# If you don't have curl but wget, replace `curl -L` with `wget -O -`.
#
# Usage
#
#   ~ $ okta-aws-cli-assume-role
#   Username: [myuser]
#   Password: [mypass]
#   ...
#
# Prerequisites
# - sudo
# - git
# - java


CONF_DIR=${OKTA_AWS_CLI_CONF_DIR:-"$HOME/.okta-aws-cli"}
CONF_FILE="$CONF_DIR/config.properties"

# Install this script into /usr/local/bin/okta-aws-cli-assume-role
if [ ! -x "/usr/local/bin/okta-aws-cli-assume-role" ]; then
    echo
    echo "Installing this script into /usr/local/bin/okta-aws-cli-assume-role (might ask for password)"

    curl -L                              \
        -o /tmp/okta-aws-cli-assume-role \
        https://raw.githubusercontent.com/stvleung/okta-aws-cli-assume-role.sh/master/okta-aws-cli-assume-role.sh

    if [ ! -w "/usr/local/bin" ]; then
        sudo="sudo"
    fi
    $sudo install -m 755 /tmp/okta-aws-cli-assume-role /usr/local/bin/okta-aws-cli-assume-role
fi

# Install repository into /opt/okta-aws-cli-assume-role if not already present
if [ ! -d "/opt/okta-aws-cli-assume-role" ]; then
    echo
    echo "Install into /opt/okta-aws-cli-assume-role (might ask for password)"

    if [ ! -w "/opt" ]; then
        sudo="sudo"
    fi
    $sudo git clone https://github.com/oktadeveloper/okta-aws-cli-assume-role.git /opt/okta-aws-cli-assume-role
fi

# Create a configuration directory and download AWS Java SDK if doesn't exist
if [ ! -d "$CONF_DIR" ]; then
    echo
    echo "Creating $CONF_DIR configuration directory"
    if mkdir -p "$CONF_DIR/lib"; then
        echo
        echo Downloading AWS Java SDK

        curl -L                      \
            -o /tmp/aws-java-sdk.zip \
            https://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip

        unzip -jo /tmp/aws-java-sdk.zip        \
            "*/lib/aws-java-sdk-*.jar"         \
            -x "*-sources.jar" "*-javadoc.jar" \
            -d "$CONF_DIR/lib"

        rm /tmp/aws-java-sdk.zip

        cd "$CONF_DIR/lib"
        ln -snf $(ls -t aws-java-sdk-*.jar | head -n 1) aws-java-sdk.jar
    else
        exit $?
    fi
fi

# Create a configuraiton file if doesn't exist
if [ ! -f "$CONF_FILE" ]; then
    touch "$CONF_FILE"
fi

# Configure tool if not already configured
if ! grep -q "OKTA_ORG=" "$CONF_FILE"; then
    read -p "Okta organization URL (eg. myorg.okta.com): " okta_org </dev/tty
    echo "OKTA_ORG=$okta_org" >> "$CONF_FILE"
fi

if ! grep -q "OKTA_AWS_APP_URL=" "$CONF_FILE"; then
    read -p "Okta AWS app URL (eg. https://myorg.okta.com/home/amazon_aws/0123456789ABCDEfghij/123): " okta_aws_app_url </dev/tty
    echo "OKTA_AWS_APP_URL=$okta_aws_app_url" >> "$CONF_FILE"
fi

cd "$CONF_DIR"
java -classpath "/opt/okta-aws-cli-assume-role/out/oktaawscli.jar:$CONF_DIR/lib/aws-java-sdk.jar" com.okta.tools.awscli </dev/tty
