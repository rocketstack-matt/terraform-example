resource "github_repository" "repo" {
  name       = "${var.project_name}-repo"
  visibility = "private"
}

resource "github_branch_protection" "branch-protection" {
  repository_id  = github_repository.repo.name
  pattern        = "main"
  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    restrict_dismissals = true
  }
}
