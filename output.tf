output "public_ip" {
    value = {
        for vm_instance_name, device_details in google_compute_instance.default : vm_instance_name => "http://${device_details.network_interface.0.access_config.0.nat_ip}"
    }
}