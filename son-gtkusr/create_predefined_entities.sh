#!/bin/bash
KEYCLOAK_PORT=8080
KEYCLOAK_USER=admin
KEYCLOAK_PASSWORD=admin
KEYCLOAK_URL=http://localhost:$KEYCLOAK_PORT

# Param: $1 = realm name
# Returns: 0 if successful, non-zero otherwise
function create_realm() {
	/opt/jboss/keycloak/bin/kcadm.sh create realms -s realm=$1 -s enabled=true -s sslRequired=none -i > /dev/null
	ret=$?
	if [ $ret -eq 0 ]; then
        	echo "Created realm [$1]"
	fi
	return $ret
}

# Params: $1 = realm, $2 = client name, $3 = redirect URI
# Returns: 0 if successful, non-zero otherwise
function create_client() {
	cid=$(/opt/jboss/keycloak/bin/kcadm.sh create clients -r $1 -s clientId=$2 -s "redirectUris=[\"$3\"]" -s serviceAccountsEnabled=true -s authorizationServicesEnabled=true -i)
	ret=$?
	if [ $ret -eq 0 ]; then
        	echo "Created client [$2] for realm [$1] (id=$cid)"
		# /opt/jboss/keycloak/bin/kcadm.sh update clients/$cid -r sonata -s serviceAccountsEnabled=true -s authorizationServicesEnabled=true
	fi
	return $ret
}

# Params: $1 = realm, $2 = role name, $3 = role description
# Returns: 0 if successful, non-zero otherwise
function create_realm_role() {
	/opt/jboss/keycloak/bin/kcadm.sh create roles -r $1 -s name=$2 -s description="$3" -i > /dev/null
	ret=$?
	if [ $ret -eq 0 ]; then
        	echo "Created role [$2] for realm [$1]"
	fi
	return $ret
}


echo
echo "------------------------------------------------------------------------"
echo "*** Verifying if Keycloak server is up and listening on $KEYCLOAK_URL"
retries=0
until [ $(curl --connect-timeout 15 --max-time 15 -k -s -o /dev/null -I -w "%{http_code}" $KEYCLOAK_URL) -eq 200 ]; do
    	#printf '.'
    	sleep 5
    	let retries="$retries+1"
    	if [ $retries -eq 12 ]; then
		echo "Timeout waiting for Keycloak on $KEYCLOAK_URL"
		exit 1
	fi
done

echo "Keycloak server detected! Creating predefined entities..."

# Log in to create session:
/opt/jboss/keycloak/bin/kcadm.sh config credentials --server $KEYCLOAK_URL/auth --realm master --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD -o

if [ $? -ne 0 ]; then 
	echo "Unable to login as admin"
	exit 1
fi

# Creating a realm:
create_realm sonata
 
# Creating a client:
create_client sonata adapter "http://localhost:8081/adapter"

# Creating a realm role:
create_realm_role sonata GK "see_catalogues, see_repositories"
create_realm_role sonata Catalogues "see_gatekeeper"
create_realm_role sonata Repositories "see_gatekeeper"
create_realm_role sonata Customer "read_repositories, write_repositories, run_repositories, run_catalogues"
create_realm_role sonata Developer "read_catalogues, write_catalogues"
