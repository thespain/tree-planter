#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "GoSU User" -m user
chown -R user.user /home/user
export HOME=/home/user

echo "Changing file ownerships in ${APP_ROOT} to ${USER_ID}"
chown -R $USER_ID $APP_ROOT

echo "Changing file ownership of /opt/trees to ${USER_ID}"
chown -R $USER_ID /opt/trees

exec /usr/local/bin/gosu user "$@"

