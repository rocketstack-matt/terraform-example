resource "github_team" "team" {
  name        = "${var.project_name}-team"
  description = "${var.project_name} team"
  privacy     = "closed"
}

// Copy the resource below per user to add, the resource name (team-membership) must be unique
resource "github_team_membership" "team-membership" {
  team_id  = github_team.team.id
  username = "rocketstack-matt"
  role     = "maintainer"
}

