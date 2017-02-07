#!/bin/sh

CONF_DIR=${OKTA_AWS_CLI_CONF_DIR:-"$HOME/.okta-aws-cli"}
CONF_FILE="$CONF_DIR/config.properties"

# Create a configuraiton directory if doesn't exist
if [ ! -d "$CONF_DIR" ]; then
    echo Creating ~/.okta-aws-cli configuration directory
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
    else
        exit $?
    fi
fi

# Create a configuraiton file if doesn't exist
if [ ! -f "$CONF_FILE" ]; then
    touch "$CONF_FILE"
fi

cd "$CONF_DIR"
java -classpath "/opt/okta-aws-cli-assume-role/out/oktaawscli.jar:$CONF_DIR/lib/aws-java-sdk.jar" com.okta.tools.awscli
