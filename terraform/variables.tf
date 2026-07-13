variable "helm_charts" {
    description = "Helm charts to deploy"
    type = map(object({
        name =  optional(string)
        chart = string
    }))

    default = {
        backend = {
            chart   = "oci://ghcr.io/intens-intern-project/backend"
        },
        frontend = {
            chart   = "oci://ghcr.io/intens-intern-project/frontend"
        },
        db = {
            chart   = "oci://ghcr.io/intens-intern-project/db"
        }
    }
}

variable "helm_chart_versions" {
    description = "Shallow map storing versions of each Helm chart. Overwritten by CI/CD."
    type = map(string)

    default = {
        backend = "0.1.4"
        frontend = "0.1.4"
        db = "0.1.3"
    }
}

variable "environment" {
    description = "Staging environment passed to the helm charts as a `environment` value"
    type = string
}

variable "k8s_namespace" {
    description = "Which Kubernetes namespace to deploy the helm charts onto"
    type = string
}