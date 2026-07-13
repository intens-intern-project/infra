resource "helm_release" "charts" {
    for_each = var.helm_charts
    
    name     = coalesce(each.value.name, each.key)
    chart    = each.value.chart
    version  = var.helm_chart_versions[each.key]

    set = [
        {
            name  = "environment"
            value = var.environment
        },
        {
            name  = "chart.namespace"
            value = var.k8s_namespace
        },
    ]
}