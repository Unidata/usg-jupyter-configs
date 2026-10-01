# FILE: env.nu
# Configuration for jupyterhub cluster deployment
# Anything with a "SET ME!" comment *must* be set

$env.jupyterhub.cluster = {
  # https://github.com/zonca/jupyterhub-deploy-kubernetes-jetstream/issues/104
  template: "unidata-ubuntu2204-k8s1.36.1-20260720",
  master: {count: 1, flavor: "m3.quad"},
  worker: {count: 1, flavor: "m3.quad"},
  autoscaling: "true",
  name: "fit26f",
}

$env.jupyterhub.nodegroup = {
  name: "mediums",
  flavor: "m3.medium",
  autoscaling: true,
  max_nodes: 25
}

$env.jupyterhub.zone = "ees220002.projects.jetstream-cloud.org."

$env.jupyterhub.shared_volume = {
  user_quota: 10, # Storage per user
  home_size: 300, # 25 users × 10 GB/user, with some headroom
  data_size: 100, # Requested shared storage
  values_path: "./shared-user-volume/values-nfs.yaml",
  pv_path: "./shared-user-volume/pv.yaml",
  pvc_path: "./shared-user-volume/pvc.yaml",
  job_path: "./shared-user-volume/init-shared-dir.yaml"
}

# Secrets for Dockerhub authentication, JupyterHub, and authentication secrets
$env.jupyterhub.dockerhub = "./jhub/dockerhub.yaml"
$env.jupyterhub.secrets = "./jhub/secrets.yaml"
$env.jupyterhub.authentication = "./jhub/authentication.yaml"

# Used to create jhub's values.yaml
$env.jupyterhub.jhub = {
  values_path: ./jhub/values.yaml,
  admins: [slazmo], # Course instructor
  image_name: unidata/unidata-standard, # Defaults to unidata/fit26f
  image_tag: "2026Aug13_175701_dfae",
  git_repos: [
    {
      server: null, # Defaults to https://github.com
      user: "slazmo",
      repo: "MET3601",
      branch: "teaching-2026/FALL-2026",
      dest_dir: null
    },
  ]
  desired_profiles: [Standard IDV] # Choose from: [Low Standard Medium High IDV]
  default_profile: "Standard" # Choose from the list in "desired_profiles" above
  user_placeholders: 4,
}
