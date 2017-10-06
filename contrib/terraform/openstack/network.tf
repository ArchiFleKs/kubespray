resource "openstack_networking_network_v2" "k8s_net" {
  name           = "${var.cluster_name}_k8s__net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "k8s_subnet" {
  name       = "${var.cluster_name}_k8s__subnet"
  network_id = "${openstack_networking_network_v2.k8s_net.id}"
  cidr       = "${var.private_network_cidr}"
}

resource "openstack_networking_router_v2" "k8s_router" {
  name             = "${var.cluster_name}_k8s_router"
  external_gateway = "${var.floatingip_network_id}"
}

resource "openstack_networking_router_interface_v2" "k8s_router_interface" {
  router_id = "${openstack_networking_router_v2.k8s_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.k8s_subnet.id}"
}

resource "openstack_networking_floatingip_v2" "k8s_master_fip" {
  count = "${var.number_of_k8s_masters + var.number_of_k8s_masters_no_etcd}"
  pool = "${var.floatingip_pool}"
}

resource "openstack_networking_floatingip_v2" "k8s_node_fip" {
  count = "${var.number_of_k8s_nodes}"
  pool = "${var.floatingip_pool}"
}

resource "openstack_networking_port_v2" "k8s_master_port" {
  count = "${var.number_of_k8s_masters + var.number_of_k8s_masters_no_etcd + var.number_of_k8s_masters_no_floating_ip + var.number_of_k8s_masters_no_floating_ip_no_etcd}"
  network_id = "${openstack_networking_network_v2.k8s_net.id}"
  security_group_ids = [ "${openstack_networking_secgroup_v2.k8s_master_secgroup.id}" ]
  admin_state_up = "true"
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.k8s_subnet.id}"
  }
  allowed_address_pairs {
    ip_address = "${var.kube_service_addresses}"
  }
  allowed_address_pairs {
    ip_address = "${var.kube_pods_subnet}"
  }
}

resource "openstack_networking_port_v2" "k8s_node_port" {
  count = "${var.number_of_k8s_nodes + var.number_of_k8s_nodes_no_floating_ip}"
  network_id = "${openstack_networking_network_v2.k8s_net.id}"
  security_group_ids = [ "${openstack_networking_secgroup_v2.k8s_node_secgroup.id}" ]
  admin_state_up = "true"
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.k8s_subnet.id}"
  }
  allowed_address_pairs {
    ip_address = "${var.kube_service_addresses}"
  }
  allowed_address_pairs {
    ip_address = "${var.kube_pods_subnet}"
  }
}

resource "openstack_networking_port_v2" "etcd_port" {
  count = "${var.number_of_etcd}"
  network_id = "${openstack_networking_network_v2.k8s_net.id}"
  security_group_ids = [ "${openstack_networking_secgroup_v2.etcd_secgroup.id}" ]
  admin_state_up = "true"
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.k8s_subnet.id}"
  }
}

resource "openstack_networking_port_v2" "gfs_port" {
  count = "${var.number_of_gfs_nodes_no_floating_ip}"
  network_id = "${openstack_networking_network_v2.k8s_net.id}"
  security_group_ids = [ "${openstack_networking_secgroup_v2.gfs_secgroup.id}" ]
  admin_state_up = "true"
  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.k8s_subnet.id}"
  }
}

resource "openstack_networking_secgroup_v2" "k8s_master_secgroup" {
  name        = "${var.cluster_name}_k8s_master"
  description = "Kubernetes masters security_group"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_master_secgroup_rule_open" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.k8s_master_secgroup.id}"
}

resource "openstack_networking_secgroup_v2" "k8s_node_secgroup" {
  name        = "${var.cluster_name}_k8s_nodes"
  description = "Kubernetes nodes security_group"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_node_secgroup_rule_open" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.k8s_node_secgroup.id}"
}

resource "openstack_networking_secgroup_v2" "etcd_secgroup" {
  name        = "${var.cluster_name}_etcd"
  description = "Etcd nodes security_group"
}

resource "openstack_networking_secgroup_rule_v2" "etcd_secgroup_rule_open" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.etcd_secgroup.id}"
}
resource "openstack_networking_secgroup_v2" "gfs_secgroup" {
  name        = "${var.cluster_name}_gfs"
  description = "GFS nodes security_group"
}

resource "openstack_networking_secgroup_rule_v2" "gfs_secgroup_rule_open" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.gfs_secgroup.id}"
}
