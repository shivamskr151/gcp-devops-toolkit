# Firewall Rules Module
resource "google_compute_firewall" "rules" {
  for_each = {
    for rule in var.rules : rule.name => rule
  }

  name          = each.value.name
  description   = each.value.description
  network       = var.network
  direction     = each.value.direction
  priority      = each.value.priority
  source_ranges = each.value.direction == "INGRESS" ? each.value.source_ranges : null
  target_tags   = each.value.target_tags

  dynamic "allow" {
    for_each = each.value.allowed
    content {
      protocol = allow.value.protocol
      # ICMP and other protocols don't use ports
      ports    = length(allow.value.ports) > 0 ? allow.value.ports : null
    }
  }

  dynamic "deny" {
    for_each = each.value.denied != null ? each.value.denied : []
    content {
      protocol = deny.value.protocol
      # ICMP and other protocols don't use ports
      ports    = length(deny.value.ports) > 0 ? deny.value.ports : null
    }
  }

  # Lifecycle rule to ensure firewall rules can be deleted cleanly
  lifecycle {
    create_before_destroy = false
  }
}

