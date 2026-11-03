# LROSE TITAN Tutorial JHub

This cluster is for the LROSE TITAN Virtual Workshop to be held October 29, 2026. It's deployed on the Unidata allocation on behalf of LROSE on top of an out of use cluster (rsmas26f). As such it has a few differences to our standard deployments and from the standard LROSE-Hub:

- Using the lrosehub26 Docker image + plotly
  - [Open PR](https://github.com/nsf-lrose/lrose-gateway/pull/22)
  - [lrosehub repo](https://github.com/nsf-lrose/lrose-gateway)
- Doesn't have virtual desktop support
- Doesn't have LROSE-Nightly support

# Notes

## Growing the RSMAS Volume

The RSMAS cluster that's being reused has a total shared volume size of 150GB. With an estimated 30+ workshop participants and a shared data size of 50GB, a volume size of 450GB seems appropriate.

We must grow the existing `jupyterhub-home-nfs` volume via the openstack CLI:

```bash
openstack --os-volume-api-version 3.42 volume set \
    --size 450 \
    $VOLUME_ID
```

In principle, the `auto-xfs-resizer` should run `xfs_growfs` every 5 minutes to resize the filesystem. However this was observed to not be the case, perhaps due to the volume being mounted to a machine during the resize. Executing a shell into the resizer Pod and running `df -h` or `lsblk` did not show the new volume size.

We can "turn it off and back on" to "fix" this:

```bash
# Turn it off
kubectl scale deployment/home-nfs \
    -n jupyterhub-home-nfs \
    --replicas=0

# Ensure the volume is free before turning back on
openstack volume show $VOLUME_ID

# Turn it back on
kubectl scale deployment/home-nfs \
    -n jupyterhub-home-nfs \
    --replicas=1
```

Now, running the same `df -h` or `lsblk` commands show the expected volume size.

## Increase Max Node Count

To increase the max node count of the cluster you can run:

```bash
openstack coe nodegroup update $CLUSTER mediums replace max_node_count=30
```
