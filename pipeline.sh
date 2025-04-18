#!/bin/bash

export OS_AUTH_TYPE=v3applicationcredential
export OS_AUTH_URL=https://identity.cloud.muni.cz/v3
export OS_IDENTITY_API_VERSION=3
export OS_REGION_NAME="brno1"
export OS_INTERFACE=public
export OS_APPLICATION_CREDENTIAL_ID=89b86f07b40842eca6802deec1828a53
export OS_APPLICATION_CREDENTIAL_SECRET=5qcx-IO5AlHV4E8rUw2EfUMnD_X3BZEtuHsLwQppqcPSngYiDP5v8hpPAJ7sh8ZTRIlGBhrOL8ufRpNtE3A9XA

export AWS_ACCESS_KEY_ID=bbe6c25a57bd4607b24022b94b521dc3
export AWS_SECRET_ACCESS_KEY=547d6ef7301544c2a81fadee22d79367

export TF_VAR_KYPO_ENDPOINT="https://images.crp.kypo.muni.cz"
export TF_VAR_CI_PROJECT_URL="https://github.com/xpanov/cshcz-test-image"
export TF_VAR_CI_COMMIT_SHORT_SHA="2fd7acb"

export KYPO_USERNAME=user-2
export KYPO_PASSWORD=9frLVwLIya

export NAME="ubuntu"
export PACKER_LOG=1


# packer plugins install github.com/hashicorp/qemu
# packer plugins install github.com/hashicorp/virtualbox
# packer plugins install github.com/hashicorp/vagrant

# sudo apt update && sudo apt install -y qemu-system-x86

# Work with terraform
packer build -only=qemu $NAME.json
exit 0
# packer build -only=qemu kali.json
# tofu destroy
tofu init
tofu plan -target=module.topology.openstack_images_image_v2.test_image
tofu apply


# Functions
get_version_from_changelog() {          
    test ! -z "$KEY"
    if [ -z "$VERSION" ]; then
        VERSION=$(cat CHANGELOG.md | sed -r -e "/##\s+.*\[$KEY-[0-9]+\.[0-9]+\.[0-9]+\]/!d" -e "s/.*$KEY-([0-9]+\.[0-9]+\.[0-9]+).*/\1/" | sort --version-sort --reverse | head -n 1)
        test ! -z "$VERSION"
    fi
    echo "$VERSION"
}
git_tag() {
    echo "git_tag"
    # git config user.name "$GITLAB_USER_NAME"; git config user.email "$GITLAB_USER_EMAIL"
    # git tag -a "$KEY-$VERSION" -m "$KEY version $VERSION"
    # git push https://root:$ACCESS_TOKEN@$CI_SERVER_HOST/$CI_PROJECT_PATH.git "$KEY-$VERSION"
}
upload_image_to_openstack() {
    openstack image create --file target-qemu/* --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --property hw_rng_model=virtio --property hw_qemu_guest_agent=yes --property os_require_quiesce=yes --property os_type=$TYPE --property os_distro=$DISTRO --property owner_specified.openstack.version=$VERSION --property owner_specified.openstack.gui_access=$GUI_ACCESS --property owner_specified.openstack.created_by=munikypo --shared $CI_PROJECT_NAME-$VERSION
}
upload_image_to_openstack_object_store() {
    cd target-qemu
    IMAGE_FILENAME=$(ls)
    mv $IMAGE_FILENAME $IMAGE_FILENAME.raw

    s3cmd -c $S3_CREDENTIALS get s3://kypo-images/SHA256SUMS SHA256SUMS
    s3cmd -c $S3_CREDENTIALS get s3://kypo-images/MD5SUMS MD5SUMS
    zip $CI_PROJECT_NAME.raw.zip $IMAGE_FILENAME.raw
    sed -i "/$CI_PROJECT_NAME.raw.zip/d" SHA256SUMS
    sha256sum $CI_PROJECT_NAME.raw.zip >> SHA256SUMS
    sed -i "/$CI_PROJECT_NAME.raw.zip/d" MD5SUMS
    md5sum $CI_PROJECT_NAME.raw.zip >> MD5SUMS

    qemu-img convert -f raw -O qcow2 $IMAGE_FILENAME.raw $CI_PROJECT_NAME.qcow2
    sed -i "/$CI_PROJECT_NAME.qcow2/d" SHA256SUMS
    sha256sum $CI_PROJECT_NAME.qcow2 >> SHA256SUMS
    sed -i "/$CI_PROJECT_NAME.qcow2/d" MD5SUMS
    md5sum $CI_PROJECT_NAME.qcow2 >> MD5SUMS

    sort -k 2 -o SHA256SUMS SHA256SUMS
    sort -k 2 -o MD5SUMS MD5SUMS
    s3cmd -c $S3_CREDENTIALS put $CI_PROJECT_NAME.qcow2 $CI_PROJECT_NAME.raw.zip SHA256SUMS MD5SUMS s3://kypo-images
    cd -
}


# Continue
get_version_from_changelog

mkdir -p target-qemu
openstack image save --file "target-qemu/$NAME" "$CI_PROJECT_NAME-$CI_COMMIT_SHORT_SHA" # pushes the img to openstach

upload_image_to_openstack

HEAD_IMAGE_ID=$(openstack image show --column id --format value $CI_PROJECT_NAME-$VERSION)
# If previous image version exists, delete it or rename it. Once all our images follow the latest naming convention, this block can be simplified
if openstack image show $CI_PROJECT_NAME > /dev/null; then
    PREV_VERSION=$(openstack image show $CI_PROJECT_NAME --column properties --format json | jq '.properties."owner_specified.openstack.version"' -re) || PREV_VERSION=0.1.0
    if openstack image show $CI_PROJECT_NAME-$PREV_VERSION > /dev/null; then
        openstack image delete $CI_PROJECT_NAME || openstack image set $CI_PROJECT_NAME --name $CI_PROJECT_NAME-DEPRECATED
    else
        openstack image set $CI_PROJECT_NAME --name $CI_PROJECT_NAME-$PREV_VERSION
    fi
fi
openstack image set $CI_PROJECT_NAME-$VERSION --name $CI_PROJECT_NAME

upload_image_to_openstack

STABLE_IMAGE_ID=$(openstack image show --column id --format value $CI_PROJECT_NAME-$VERSION)

git_tag

# Share the image to other OpenStack projects
while read -r PROJECT_ID; do
    openstack image add project $HEAD_IMAGE_ID $PROJECT_ID
    openstack image add project $STABLE_IMAGE_ID $PROJECT_ID
done < <(echo $APPLICATION_CREDENTIALS | jq -r '.[] | .project_id')

# Accept the sharing from each project
while read -r APP_ID && read -r APP_SECRET; do
    OS_APPLICATION_CREDENTIAL_ID=$APP_ID
    OS_APPLICATION_CREDENTIAL_SECRET=$APP_SECRET
    openstack image set --accept $HEAD_IMAGE_ID
    openstack image set --accept $STABLE_IMAGE_ID
done < <(echo $APPLICATION_CREDENTIALS | jq -r '.[] | (.app_cred_id, .app_cred_secret)')

if [ $TYPE != "windows" ]; then # this is only cause of licensiung. pusg the img to a commen storage/'repo'
    # .upload-image-to-openstack-object-store
    upload_image_to_openstack_object_store
    # cd target-qemu
    # IMAGE_FILENAME=$(ls)
    # mv $IMAGE_FILENAME $IMAGE_FILENAME.raw

    # s3cmd -c $S3_CREDENTIALS get s3://kypo-images/SHA256SUMS SHA256SUMS
    # s3cmd -c $S3_CREDENTIALS get s3://kypo-images/MD5SUMS MD5SUMS
    # zip $CI_PROJECT_NAME.raw.zip $IMAGE_FILENAME.raw
    # sed -i "/$CI_PROJECT_NAME.raw.zip/d" SHA256SUMS
    # sha256sum $CI_PROJECT_NAME.raw.zip >> SHA256SUMS
    # sed -i "/$CI_PROJECT_NAME.raw.zip/d" MD5SUMS
    # md5sum $CI_PROJECT_NAME.raw.zip >> MD5SUMS

    # qemu-img convert -f raw -O qcow2 $IMAGE_FILENAME.raw $CI_PROJECT_NAME.qcow2
    # sed -i "/$CI_PROJECT_NAME.qcow2/d" SHA256SUMS
    # sha256sum $CI_PROJECT_NAME.qcow2 >> SHA256SUMS
    # sed -i "/$CI_PROJECT_NAME.qcow2/d" MD5SUMS
    # md5sum $CI_PROJECT_NAME.qcow2 >> MD5SUMS

    # sort -k 2 -o SHA256SUMS SHA256SUMS
    # sort -k 2 -o MD5SUMS MD5SUMS
    # s3cmd -c $S3_CREDENTIALS put $CI_PROJECT_NAME.qcow2 $CI_PROJECT_NAME.raw.zip SHA256SUMS MD5SUMS s3://kypo-images
    # cd -
fi

# Destroy
tofu destroy # it also calls KYPO API to destroy the SB
          
# todo we probably dont need it
curl --header "Private-Token:${TF_PASSWORD:-$CI_JOB_TOKEN}" --request DELETE "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${TF_STATE_NAME}" || true


# # Initialize Terraform
# echo "Initializing Terraform..."
# tofu init

# # Validate Terraform configuration
# echo "Validating Terraform configuration..."
# tofu validate

# # Plan the deployment
# echo "Planning Terraform deployment..."
# tofu plan

# # Apply the Terraform configuration
# echo "Applying Terraform configuration..."
# tofu apply -auto-approve

# # Get and display the instance IP
# echo "Fetching instance IP..."
# tofu output instance_ip
