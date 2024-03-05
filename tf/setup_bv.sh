#!/bin/bash

echo "Checking tools"
which oci 2>&1 1>/dev/null
if [[ $? -eq 1 ]]; then
	echo "Installing tools..."
	dnf install jq python36-oci-cli -yq
else
  echo "Tools found."
fi

set -e

export OCI_CLI_AUTH=instance_principal

DEV="/dev/sdb"
INSTANCE_OCID=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.id')
COMPARTMENT_OCID=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.compartmentId')
AD=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r '.availabilityDomain')

# Get the OCID of the block volume
BLOCK_VOLUME_OCID=$(oci bv volume list --compartment-id=${COMPARTMENT_OCID} --lifecycle-state AVAILABLE --availability-domain ${AD} | jq -r '.data[0].id')
if [[ $BLOCK_VOLUME_OCID == "" ]]; then
	echo "Can't find valid block volume. Exiting."
	exit 1
else
	echo "Found block volume to mount: $BLOCK_VOLUME_OCID"
fi

# Check if the volume is already attached to the instance
echo "Checking current volume state..."
ATTACHED_INSTANCE=$(oci compute volume-attachment list --volume-id $BLOCK_VOLUME_OCID --compartment-id $COMPARTMENT_OCID | jq -r '.data | sort_by(."time-created") | last | ."instance-id"')
STATE=$(oci compute volume-attachment list --volume-id $BLOCK_VOLUME_OCID --compartment-id $COMPARTMENT_OCID | jq -r '.data | sort_by(."time-created") | last | ."lifecycle-state"')
if [[ "$ATTACHED_INSTANCE" == "$INSTANCE_OCID" && "$STATE" == "ATTACHED" ]]; then
	echo "Block volume is already attached to the current instance"
elif [[ "$ATTACHED_INSTANCE" == "" || "$STATE" == "DETACHED" ]]; then
	# The volume is not attached, attach it to the instance
	echo "Block volume $BLOCK_VOLUME_OCID is in state $STATE, requesting attachment..."
	oci compute volume-attachment attach --volume-id $BLOCK_VOLUME_OCID --instance-id $INSTANCE_OCID --type paravirtualized

	# Wait for the attachment to complete
	ATTACH_STATUS=""
	while [[ "$ATTACH_STATUS" != "ATTACHED" ]]; do
		sleep 2
		ATTACH_STATUS=$(oci compute volume-attachment list --volume-id $BLOCK_VOLUME_OCID --compartment-id $COMPARTMENT_OCID | jq -r '.data | sort_by(."time-created") | last | ."lifecycle-state"')
		echo "Block volume $BLOCK_VOLUME_OCID is in state $ATTACH_STATUS..."
	done
	echo "Block volume $BLOCK_VOLUME_OCID attached to instance"
else
	# the volume is attached already to another instance
	echo "The volume $BLOCK_VOLUME_OCID in state $STATE is already attached to another instance $ATTACHED_INSTANCE. Exiting."
	exit 1
fi

if [[ $(lsblk -f | grep "sdb1" | grep "ext4") != "" ]]; then
	echo "Volume $DEV already has a filesystem"
else
	echo "Creating partition and filesystem on $DEV"
	parted --script $DEV mklabel gpt mkpart primary ext4 0% 100%
	mkfs.ext4 -L srv ${DEV}1
fi

if [[ -d /srv ]]; then
	echo "/srv exists"
else
	mkdir /srv
	echo "/srv created"
fi

set +e
echo "Mounting ${DEV}1 on /srv"
mount ${DEV}1 /srv
echo "${DEV}1 mounted and ready"

echo "Runnig OKE script"
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh
