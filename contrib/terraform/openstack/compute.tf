resource "openstack_compute_keypair_v2" "k8s_keypair" {
    name = "${var.cluster_name}"
    public_key = "${file(var.public_key_path)}"
}

resource "openstack_compute_instance_v2" "k8s_master" {
    name = "${var.cluster_name}-k8s-master-${count.index+1}"
    count = "${var.number_of_k8s_masters}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_k8s_master}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.k8s_master_port.*.id, count.index)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "etcd,kube-master,kube-node,k8s-cluster,vault"
        kubespray_groups = "etcd,kube-master,kube-node,k8s-cluster,vault"
    }
}

resource "openstack_compute_floatingip_associate_v2" "k8s_master_fip" {
  count = "${var.number_of_k8s_masters}"
  floating_ip = "${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.k8s_master.*.id, count.index)}"
}

resource "openstack_compute_instance_v2" "k8s_master_no_etcd" {
    name = "${var.cluster_name}-k8s-master-ne-${count.index+1}"
    count = "${var.number_of_k8s_masters_no_etcd}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_k8s_master}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.k8s_master_port.*.id, count.index + var.number_of_k8s_masters)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "kube-master,kube-node,k8s-cluster,vault"
        kubespray_groups = "kube-master,kube-node,k8s-cluster,vault"
    }
}

resource "openstack_compute_floatingip_associate_v2" "k8s_master_no_etcd_fip" {
  count = "${var.number_of_k8s_masters_no_etcd}"
  floating_ip = "${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.k8s_master_no_etcd.*.id, count.index + var.number_of_k8s_masters )}"
}

resource "openstack_compute_instance_v2" "k8s_master_no_floating_ip" {
    name = "${var.cluster_name}-k8s-master-nf-${count.index+1}"
    count = "${var.number_of_k8s_masters_no_floating_ip}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_k8s_master}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.k8s_master_port.*.id, count.index + var.number_of_k8s_masters + var.number_of_k8s_masters_no_etcd)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "etcd,kube-master,kube-node,k8s-cluster,vault,no-floating"
        kubespray_groups = "etcd,kube-master,kube-node,k8s-cluster,vault,no-floating"
    }

    provisioner "local-exec" {
        command = "sed s/USER/${var.ssh_user}/ contrib/terraform/openstack/ansible_bastion_template.txt | sed s/BASTION_ADDRESS/${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, 0)}/ > contrib/terraform/openstack/group_vars/no-floating.yml"
    }
}

resource "openstack_compute_instance_v2" "k8s_master_no_floating_ip_no_etcd" {
    name = "${var.cluster_name}-k8s-master-ne-nf-${count.index+1}"
    count = "${var.number_of_k8s_masters_no_floating_ip_no_etcd}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_k8s_master}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.k8s_master_port.*.id, count.index + var.number_of_k8s_masters + var.number_of_k8s_masters_no_etcd + var.number_of_k8s_masters_no_floating_ip)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "kube-master,kube-node,k8s-cluster,vault,no-floating"
        kubespray_groups = "kube-master,kube-node,k8s-cluster,vault,no-floating"
    }
    provisioner "local-exec" {
        command = "sed s/USER/${var.ssh_user}/ contrib/terraform/openstack/ansible_bastion_template.txt | sed s/BASTION_ADDRESS/${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, 0)}/ > contrib/terraform/openstack/group_vars/no-floating.yml"
    }
}

resource "openstack_compute_instance_v2" "etcd" {
    name = "${var.cluster_name}-etcd-${count.index+1}"
    count = "${var.number_of_etcd}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_etcd}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.etcd_port.*.id, count.index)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "etcd,vault,no-floating"
        kubespray_groups = "etcd,vault,no-floating"
    }
    provisioner "local-exec" {
        command = "sed s/USER/${var.ssh_user}/ contrib/terraform/openstack/ansible_bastion_template.txt | sed s/BASTION_ADDRESS/${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, 0)}/ > contrib/terraform/openstack/group_vars/no-floating.yml"
    }
}

resource "openstack_compute_instance_v2" "glusterfs_node_no_floating_ip" {
    name = "${var.cluster_name}-gfs-node-nf-${count.index+1}"
    count = "${var.number_of_gfs_nodes_no_floating_ip}"
    image_name = "${var.image_gfs}"
    flavor_id = "${var.flavor_gfs_node}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"
    network {
      port = "${element(openstack_networking_port_v2.gfs_port.*.id, count.index)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user_gfs}"
        groups = "gfs-cluster,network-storage"
        kubespray_groups = "gfs-cluster,network-storage"
    }

    volume {
        volume_id = "${element(openstack_blockstorage_volume_v2.glusterfs_volume.*.id, count.index)}"
    }

    provisioner "local-exec" {
      command = "sed s/USER/${var.ssh_user}/ contrib/terraform/openstack/ansible_bastion_template.txt | sed s/BASTION_ADDRESS/${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, 0)}/ > contrib/terraform/openstack/group_vars/gfs-cluster.yml"
    }
}

resource "openstack_blockstorage_volume_v2" "glusterfs_volume" {
  name = "${var.cluster_name}-gfs-nephe-vol-${count.index+1}"
  count = "${var.number_of_gfs_nodes_no_floating_ip}"
  description = "Non-ephemeral volume for GlusterFS"
  size = "${var.gfs_volume_size_in_gb}"
}

resource "openstack_compute_instance_v2" "k8s_node" {
    name = "${var.cluster_name}-k8s-node-${count.index+1}"
    count = "${var.number_of_k8s_nodes}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_k8s_node}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.k8s_node_port.*.id, count.index)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "kube-node,k8s-cluster,vault"
        kubespray_groups = "kube-node,k8s-cluster,vault"
    }
}

resource "openstack_compute_floatingip_associate_v2" "k8s_node_fip" {
  count = "${var.number_of_k8s_nodes}"
  floating_ip = "${element(openstack_networking_floatingip_v2.k8s_node_fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.k8s_node.*.id, count.index + var.number_of_k8s_masters + var.number_of_k8s_masters_no_etcd)}"
}

resource "openstack_compute_instance_v2" "k8s_node_no_floating_ip" {
    name = "${var.cluster_name}-k8s-node-nf-${count.index+1}"
    count = "${var.number_of_k8s_nodes_no_floating_ip}"
    image_name = "${var.image}"
    flavor_id = "${var.flavor_k8s_node}"
    key_pair = "${openstack_compute_keypair_v2.k8s_keypair.name}"

    network {
      port = "${element(openstack_networking_port_v2.k8s_node_port.*.id, count.index + var.number_of_k8s_nodes)}"
    }

    metadata = {
        ansible_user = "${var.ssh_user}"
        groups = "kube-node,k8s-cluster,vault,no-floating"
        kubespray_groups = "kube-node,k8s-cluster,vault,no-floating"
    }
    provisioner "local-exec" {
      command = "sed s/USER/${var.ssh_user}/ contrib/terraform/openstack/ansible_bastion_template.txt | sed s/BASTION_ADDRESS/${element(openstack_networking_floatingip_v2.k8s_master_fip.*.address, 0)}/ > contrib/terraform/openstack/group_vars/no-floating.yml"
    }
}
