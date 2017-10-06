terraform {
  backend "swift" {
    container = "k8s-state"
  }
}

data "terraform_remote_state" "remote_state" {
  backend = "swift"
  config {
    container = "k8s-state"
  }
}

provider "openstack" {
  user_name   = "${var.username}"
  tenant_name = "${var.project_name}"
  password    = "${var.password}"
  auth_url    = "${var.auth_url}"
}

#output "msg" {
#    value = "Your hosts are ready to go!\nYour ssh hosts are: ${join(", ", openstack_networking_floatingip_v2.k8s_master.*.address )}"
#}
