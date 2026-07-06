resource "helm_release" "charts" {
    for_each = var.helm_charts
    
    name     = try(each.value.name, each.key)
    chart    = each.value.chart
    version  = each.value.version
}