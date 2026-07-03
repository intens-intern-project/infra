variable "helm_charts" {
    description = "Local helm charts to deploy"
    default = {
        backend = {
            // name = "backend"
            // chart = "../helmcharts/backend"
        },
        frontend = {},
        db = {}
    }
}