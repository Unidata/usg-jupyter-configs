# FILE: env.nu
# Configuration for jupyterhub cluster deployment
# Anything with a "SET ME!" comment *must* be set

$env.jupyterhub.cluster = {
  template: "unidata-ubuntu2204-k8s1.36.1-20260720",
  master: {count: 1, flavor: "m3.quad"},
  worker: {count: 1, flavor: "m3.quad"},
  autoscaling: "true",
  name: uf26f,
}

$env.jupyterhub.nodegroup = {
  name: "mediums",
  flavor: "m3.medium",
  autoscaling: true,
  max_nodes: 20
}

$env.jupyterhub.zone = "ees220002.projects.jetstream-cloud.org."

$env.jupyterhub.shared_volume = {
  user_quota: 15, # Storage per user
  home_size: 400, # Total size of home dir volume, accounting for all users; In GB; if this is left null, users will not have persistent storage
  data_size: 30, # Total size of /share mount, in GB; if this is left null, no additional storage is allocated for shared data
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
  admins: [],
  image_name: unidata/uf26f,
  image_tag: 2026Aug06_161007_5e24,
  git_repos: [
    {
      server: https://github.com,
      user: srmullens,
      repo: pragmatic_python_for_weather,
      branch: main,
      dest_dir: pragmatic_python_for_weather
    },
  ],
  user_placeholders: 4, # Change to `null` to disable user_placeholders
  desired_profiles: [Medium IDV] # Choose from: [Low Standard Medium High IDV]
  default_profile: "Medium" # Choose from the list in "desired_profiles" above
}
