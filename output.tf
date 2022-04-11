output "public_ip" {
    value = {
        for k, v in google_compute_instance.default : k => "http://${v.network_interface.0.access_config.0.nat_ip}"
    }
}