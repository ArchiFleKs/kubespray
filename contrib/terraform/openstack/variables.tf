variable "username" {
  description = "Your openstack username"
}

variable "password" {
  description = "Your openstack password"
}

variable "project_name" {
  description = "Your openstack tenant/project"
}

variable "auth_url" {
  description = "Your openstack auth URL"
}

variable "cluster_name" {
  default = "k8s"
}

variable "number_of_k8s_masters" {
  default = 1
}

variable "number_of_k8s_masters_no_etcd" {
  default = 0
}

variable "number_of_etcd" {
  default = 0
}

variable "number_of_k8s_masters_no_floating_ip" {
  default = 0
}

variable "number_of_k8s_masters_no_floating_ip_no_etcd" {
  default = 0
}

variable "number_of_k8s_nodes" {
  default = 3
}

variable "number_of_k8s_nodes_no_floating_ip" {
  default = 0
}

variable "number_of_gfs_nodes_no_floating_ip" {
  default = 0
}

variable "gfs_volume_size_in_gb" {
  default = 75
}

variable "public_key_path" {
  description = "The path of the ssh pub key"
  default = "~/.ssh/id_rsa.pub"
}

variable "image" {
  description = "the image to use"
  default = "ubuntu-16.04"
}

variable "image_gfs" {
  description = "Glance image to use for GlusterFS"
  default = "ubuntu-16.04"
}

variable "ssh_user" {
  description = "used to fill out tags for ansible inventory"
  default = "ubuntu"
}

variable "ssh_user_gfs" {
  description = "used to fill out tags for ansible inventory"
  default = "ubuntu"
}

variable "flavor_k8s_master" {
  default = 3
}

variable "flavor_k8s_node" {
  default = 3
}

variable "flavor_etcd" {
  default = 3
}

variable "flavor_gfs_node" {
  default = 3
}

variable "floatingip_network_id" {
  description = "ID of the floating ip pool to use"
  default = "public"
}

variable "floatingip_pool" {
  description = "name of the floating ip pool to use"
  default = "public"
}

variable "private_network_cidr" {
  description = "private network cidr"
  default = "10.42.42.0/24"
}

variable "kube_pods_subnet" {
  description = "Pods subnet CIDR"
  default = "10.233.64.0/18"
}

variable "kube_service_addresses" {
  description = "Kubernetes Services ClusterIP CIDR"
  default = "10.233.0.0/18"
}
