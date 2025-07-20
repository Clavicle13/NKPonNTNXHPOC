# NKPonNTNXHPOC
Scripts to install NKP Management and Workload Clusters on Nutanix HPOC facility

Procedure

1. Ensure you go through the pre-requsities and the preparatory steps for the Bastion Host
2. Modify the configuration file nkp-config.conf to set values for the management cluster
3. Do a dry run like so

DRYRUN=TRUE ./c-secure.bash

4. If the dry run passes, capture the YAML file
5. Verify the YAML file
6. Do an actual run like so

./c-secure.bash

7. After setting up the management cluster, enable Harbor (and it's dependencies) in the management cluster
8. Log into Harbor and create a Harbor Project
9. Push the nkp air-gapped bundles onto Harbor Project
10. Ensure you create a workspace on the Management cluster and remember the workspace name
11. Modify the configuration file nkp-workload-config.conf to set values for the workload cluster
12. Do a dry run like so

DRYRUN=TRUE ./c-workload.bash

13. If the dry run passes, capture the YAML file
14. Verify the YAML file
15. Do an actual run like so

./c-workload.bash

16. Turn on Istio, Kaili on the workload cluster
17. Download Example Voting App
18. Modify the YAML file to include the istio-injection=enabled key value label



