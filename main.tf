provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
    kubernetes = {
        config_path = "~/.kube/config"
    }
}

resource "helm_release" "backend" {
    chart = "./helmcharts/backend"
    name = "backend"
}

resource "helm_release" "frontend" {
    chart = "./helmcharts/frontend"
    name = "frontend"
}

resource "helm_release" "db" {
    chart = "./helmcharts/db"
    name = "db"
}