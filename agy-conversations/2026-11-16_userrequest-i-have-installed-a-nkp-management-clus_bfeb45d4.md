# <USER_REQUEST>

- **Session UUID:** `bfeb45d4-29e9-4c3c-8a46-9029f4bc35bd`
- **Last Modified:** 2026-11-16 13:35:40

---

## User

<USER_REQUEST>
I have installed a NKP Management cluster and it is operational with two workspaces, finance and engineering. There is a workload cluster in each workspace.
In the finance workspace, the workload cluster is called salary and in the engineering workspace the workload cluster is called databases
Prism Central IP is 10.136.231.7:9440 and the username is "admin" and password is "nx2Tech548!"
kubectl has been properly pathed and KUBECONFIG properly exported.
You should be able to access all three kubenetes clusters via the command line.
I wish to install NDK or Nutanix Data Service for Kubernetes on salary and databases
The modules for NDK should be inside harbor
The harbor URL is https://172.16.11.120:5000/nkpdemo
The username for demo is "admin" and password is "aYm1TRfE8!HjJfj63K7%".
I have marked the nkpdemo project public anyway so you should be able to access the nkpdemo project without credentials.
check for me whether you can access the harbor nkpdemo and whether the NDK modules are inside and accessible
Do not do the NDK installation as yet. Just do the check first. Then check whether you can access the salary and database workload clusters to do the installation but do not do the installation as yet.
</USER_REQUEST>
<ADDITIONAL_METADATA>
The current local time is: 2026-11-16T13:01:14Z.
</ADDITIONAL_METADATA>
<USER_SETTINGS_CHANGE>
The user changed setting `Model Selection` from None to Gemini 4 Hydrogen (Medium). No need to comment on this change if the user doesn't ask about it. If reporting what model you are, please use a human readable name instead of the exact string.
</USER_SETTINGS_CHANGE>

---

## Assistant

Both Harbor (`nkpdemo`) and the workload clusters (`salary` and `databases`) are accessible, and no NDK installation has been performed.

### 1. Harbor (`https://172.16.11.120:5000/nkpdemo`)
- **Access:** Confirmed accessible without credentials via the Harbor v2.0 API (`https://172.16.11.120:5000/api/v2.0/projects/nkpdemo/...`). *(Note: direct unauthenticated requests to `/v2/.../tags/list` return `UNAUTHORIZED` requesting an authorization header, which is expected for Harbor's OCI token auth flow.)*
- **NDK Modules Found in `nkpdemo`:**
  - `nkpdemo/mesosphere/charts/ndk` (tag: `2.3.0`)
  - `nkpdemo/nutanix-cloud-native/nkp-nutanix-product-catalog/ndk` (tag: `2.3.0`)
  - `nkpdemo/nutanix/ndk-manager` (tag: `2.3.0`)
  - `nkpdemo/nutanix/ndk-ui` (1 artifact)
  - `nkpdemo/nutanix/ndk-job-scheduler` (1 artifact)
  - `nkpdemo/nutanix/ndk-infra-manager` (1 artifact)

### 2. Kubernetes Workload Clusters
All three contexts from `kubectl config get-contexts` are reachable and healthy (`v1.36.2`):

| Cluster | Context | Status |
| --- | --- | --- |
| **salary** | `salary-admin@salary` | Accessible — 7 nodes `Ready` (3 control-plane, 4 workers) |
| **databases** | `databases-admin@databases` | Accessible — 7 nodes `Ready` (3 control-plane, 4 workers) |
| **practice1** (Management) | `practice1-admin@practice1` | Accessible — 7 nodes `Ready` (3 control-plane, 4 workers) |

Let me know when you are ready to proceed with the NDK installation on `salary` and `databases`.

---

## User

<USER_REQUEST>
ok, i need you to install NDK on workload cluster salary and databases but not practice1, which is the NKP management cluster itself. If the installation is successful, i need you to list the commands which lead to the successfull installation so that I can use the command the next time I setup a similar lab cluster
</USER_REQUEST>
<ADDITIONAL_METADATA>
The current local time is: 2026-11-16T13:06:47Z.
</ADDITIONAL_METADATA>

---

## Assistant

Installing the Harbor CA certificate (`kommander-ca`) onto the `databases` cluster nodes and restarting `containerd` so it can pull the NDK images from Harbor; waiting for the task to complete.

---

## Assistant

NDK (`ndk-2.3.0`) has been successfully installed on both **`salary`** and **`databases`**, and was **not** installed on the management cluster (`practice1`).

### Verification Results

| Cluster | Workspace | HelmRelease (`ntnx-system/ndk`) | Pod Status (`ntnx-system`) |
| --- | --- | --- | --- |
| **salary** | `finance-cmnj8` (`finance-cmnj8-4584q`) | `True` — `Helm install succeeded for release ntnx-system/ndk.v1 with chart ndk@2.3.0` | `ndk-controller-manager-69577d84cf-68rvj` (`4/4 Running`) |
| **databases** | `engineering-scr9h` (`engineering-scr9h-24454`) | `True` — `Helm install succeeded for release ntnx-system/ndk.v1 with chart ndk@2.3.0` | `ndk-controller-manager-69577d84cf-rm69d` (`4/4 Running`) |
| **practice1** (Management) | `kommander-workspace` | Not deployed | No NDK pods |

---

### Commands Used for Installation

#### 1. List workspaces to get the exact workspace names
```bash
nkp get workspaces --context practice1-admin@practice1
```

#### 2. Deploy NDK (`ndk-2.3.0`) to each workload cluster via NKP AppDeployment
```bash
nkp create appdeployment ndk \
  --app ndk-2.3.0 \
  --workspace finance-cmnj8 \
  --clusters salary \
  --context practice1-admin@practice1

nkp create appdeployment ndk \
  --app ndk-2.3.0 \
  --workspace engineering-scr9h \
  --clusters databases \
  --context practice1-admin@practice1
```

#### 3. Fix Harbor TLS trust on `databases` (only needed if the cluster's `globalImageRegistryMirror` secret was created without `ca.crt`)
On `databases`, `containerd` initially failed to pull images from `https://172.16.11.120:5000/nkpdemo` with `x509: certificate signed by unknown authority` because `databases-image-registry-mirror-credentials` lacked Harbor's CA (`kommander-ca`).

To resolve this on the existing `databases` cluster:
```bash
# 1. Extract the kommander-ca certificate from the management cluster
kubectl --context practice1-admin@practice1 get secret kommander-ca -n cert-manager \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > kommander-ca.crt

# 2. Add ca.crt to the cluster's registry mirror secret on the management cluster (for future nodes)
CA_B64=$(kubectl --context practice1-admin@practice1 get secret kommander-ca -n cert-manager -o jsonpath='{.data.ca\.crt}')
kubectl --context practice1-admin@practice1 patch secret databases-image-registry-mirror-credentials \
  -n engineering-scr9h-24454 --type merge -p "{\"data\":{\"ca.crt\":\"${CA_B64}\"}}"

# 3. Install the CA cert on each node in databases and restart containerd
for ip in $(kubectl --context databases-admin@databases get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'); do
  scp -o StrictHostKeyChecking=no kommander-ca.crt konvoy@$ip:/tmp/kommander-ca.crt
  ssh -o StrictHostKeyChecking=no konvoy@$ip \
    "sudo mv /tmp/kommander-ca.crt /usr/local/share/ca-certificates/kommander-ca.crt && sudo update-ca-certificates && sudo systemctl restart containerd"
done
```
*(Tip for future lab setups: passing Harbor's `kommander-ca.crt` via `--registry-mirror-cacert` when creating the workload cluster avoids step 3.)*

#### 4. Verify deployment status
```bash
kubectl --context salary-admin@salary get helmrelease ndk -n finance-cmnj8-4584q
kubectl --context salary-admin@salary get pods -n ntnx-system

kubectl --context databases-admin@databases get helmrelease ndk -n engineering-scr9h-24454
kubectl --context databases-admin@databases get pods -n ntnx-system
```

---

## User

<USER_REQUEST>
what went wrong? I saw you troubleshooting a lot of stuff
</USER_REQUEST>
<ADDITIONAL_METADATA>
The current local time is: 2026-11-16T13:32:18Z.
</ADDITIONAL_METADATA>

---

## Assistant

Two things caused the extra troubleshooting, both on the **`databases`** cluster (`salary` installed on the first try):

1. **Difference in registry configuration between `salary` and `databases`**
   - **`salary`** was configured with `imageRegistries`, so its nodes pulled `docker.io/nutanix/...` images directly and `ndk-controller-manager` came up `4/4 Running` right away.
   - **`databases`** was configured with `globalImageRegistryMirror` pointing to `https://172.16.11.120:5000/nkpdemo` (with `preflight.cluster.caren.nutanix.com/skip: Registry`), which redirects all image pulls—including `docker.io/nutanix/...`—to Harbor.

2. **Missing Harbor CA certificate (`ca.crt`) on `databases`**
   - Harbor (`172.16.11.120:5000`) serves a TLS certificate signed by `CN=kommander-ca`.
   - The `databases-image-registry-mirror-credentials` secret on `practice1` only contained `username` and `password`—`ca.crt` was missing—and the `databases` nodes did not have `kommander-ca` in their trust store or `/etc/containerd/certs.d/_default/hosts.toml`.
   - That caused `ndk-controller-manager` on `databases` to fail with `ErrImagePull`:
     `tls: failed to verify certificate: x509: certificate signed by unknown authority`.

3. **Why it took two steps to fix**
   - Patching `ca.crt` into `databases-image-registry-mirror-credentials` on `practice1` covers future nodes, but did not update `containerd` on the already-running `databases` nodes.
   - Copying `kommander-ca.crt` onto the 7 `databases` nodes, running `update-ca-certificates`, and restarting `containerd` allowed Flux's next retry to pull the images and complete the `ndk@2.3.0` Helm install.

*(There was also a brief mid-run stream interruption right when the `AppDeployment` commands were first sent, so I re-verified and re-ran `nkp create appdeployment` before checking the pods.)*

---

## User

<USER_REQUEST>
the database cluster was installed using the script /home/nutanix/NKPonNTNXHPOC/non-airgapped/transit/workload-sammple-cli while salary cluster was installed using the Add cluster facility in the NKP management GUI. That's the primary difference. I need you to modify the file /home/nutanix/NKPonNTNXHPOC/non-airgapped/transit/workload-sammple-cli so that the next time I do this, i will not encounter registry error. Is this possible?
</USER_REQUEST>
<ADDITIONAL_METADATA>
The current local time is: 2026-11-16T13:35:06Z.
</ADDITIONAL_METADATA>

---

## Assistant

Yes—updated [workload-sammple-cli](file:///home/nutanix/NKPonNTNXHPOC/non-airgapped/transit/workload-sammple-cli) so future clusters created with it will automatically trust Harbor's TLS certificate:

1. **Extracts Harbor's CA (`kommander-ca`)** from the management cluster before creating the workload cluster:
   ```bash
   kubectl get secret kommander-ca -n cert-manager -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/harbor-ca.crt
   ```
2. **Passes `--registry-mirror-cacert /tmp/harbor-ca.crt`** to `nkp create cluster nutanix` (which populates `ca.crt` in the cluster's registry mirror secret and configures `containerd` on all nodes to trust `172.16.11.120:5000`).
3. **Removed `--skip-preflight-checks=Registry`** so the registry preflight check runs and validates the mirror and CA cert upfront instead of masking TLS errors.

---

