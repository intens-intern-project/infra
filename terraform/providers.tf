terraform {
    required_version = ">= 1.15.7"
    required_providers {
		kubernetes = {
			source = "hashicorp/kubernetes"
			version = "3.2.1"
		}

		helm = {
			source = "hashicorp/helm"
			version = "3.2.0"
		}
	}

	backend "remote" {
		hostname     = "app.terraform.io"
		organization = "iip"

		workspaces {
			prefix = "iip-"
		}
	}
}

provider "kubernetes" {
	config_path = "~/.kube/config"
}

provider "helm" {
	kubernetes = {
		config_path = "~/.kube/config"
	}
}