resource "github_team_repository" "team-repo" {
  team_id    = github_team.team.id
  repository = github_repository.repo.name
  permission = "pull"
}

