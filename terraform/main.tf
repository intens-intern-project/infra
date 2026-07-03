resource "helm_release" "charts" {
    for_each = var.helm_charts
    name     = try(each.value.name, each.key)
    chart    = try(each.value.chart, "../helmcharts/${each.key}") 
}