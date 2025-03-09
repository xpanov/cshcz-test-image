# Image CI example

This is an example how to use the CI for a KYPO image, such as [kali](https://gitlab.ics.muni.cz/muni-kypo-images/kali).

To use the CI:
- copy the files `.gitlab-ci.yml`, `terraform.tf`, `topology.yml`, `provisioning/playbook.yml`
- fill in the variables in `.gitlab-ci.yml`
- if you want to use CI for only qemu or vbox version, delete the other include from `.gitlab-ci.yml` 
- fill in `mgmt_user` in `topology.yml`, increase flavor if necesarry
- ensure the following CI/CD variables are set:
  - `TF_VAR_KYPO_ENDPOINT`
  - `KYPO_CLIENT_ID`
  - `KYPO_USERNAME`
  - `KYPO_PASSWORD`
  - `OS_APPLICATION_CREDENTIAL_ID` - credentials for OpenStack project where the qemu image will be uploaded
  - `OS_APPLICATION_CREDENTIAL_SECRET`
  - `ACCESS_TOKEN` - access token with read and write permissions to the repository
  - `APPLICATION_CREDENTIALS` - json array with OpenStack credentials to projects where the qemu image is shared
  - `S3_CREDENTIALS` - file with credentials to OpenStack object store where the qemu images are published
  - `VAGRANT_CLOUD_TOKEN` - token to Vagrant cloud where vbox images are published
