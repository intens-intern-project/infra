variable "helm_charts" {
    description = "Local helm charts to deploy"
    default = {
        backend = {
            // name = "backend"
            chart   = "oci://ghcr.io/intens-intern-project/backend"
            version = "0.1.4"
        },
        frontend = {
            chart   = "oci://ghcr.io/intens-intern-project/frontend"
            version = "0.1.4"
        },
        db = {
            chart   = "oci://ghcr.io/intens-intern-project/db"
            version = "0.1.3"
        }
    }
}