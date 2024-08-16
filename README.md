### Terraform for GitHub Management
This repo contains terraform code to:
* Create a repository
* Create a team
* Assign the team to be maintainers of the repository
* Set default branch protections

### Using this project
* [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Setup your GitHub CLI access via a [GITHUB_TOKEN](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
* Clone locally and cd to the github directory, look at the variables.tf

```json
variable organization {
  description = "Name of the Github Organization"
  type = string
  default = "YOUR-ORG"
}

variable "project_name" {
  description = "Name of the Project, no spaces"
  type = string
  default = "example-project-1"
}
```

* Whilst you can use terraform / the API to manage repositories in an account, you must have an Organisation to create and manage teams.
* Specify your unique Organisation name and set the project name you want to use. This will be a prefix for the repository and team created.

Run 
```shell 
terraform init
terraform apply
````

You will see the following output explaining what it would execute and asking for confirmation to execute

```shell
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # github_branch_protection.branch-protection will be created
  + resource "github_branch_protection" "branch-protection" {
      + allows_deletions                = false
      + allows_force_pushes             = false
      + enforce_admins                  = false
      + id                              = (known after apply)
      + lock_branch                     = false
      + pattern                         = "main"
      + repository_id                   = "example-project-1-repo"
      + require_conversation_resolution = false
      + require_signed_commits          = false
      + required_linear_history         = false

      + required_pull_request_reviews {
          + dismiss_stale_reviews           = true
          + require_last_push_approval      = false
          + required_approving_review_count = 1
          + restrict_dismissals             = true
        }
    }

  # github_repository.repo will be created
  + resource "github_repository" "repo" {
      + allow_auto_merge            = false
      + allow_merge_commit          = true
      + allow_rebase_merge          = true
      + allow_squash_merge          = true
      + archived                    = false
      + default_branch              = (known after apply)
      + delete_branch_on_merge      = false
      + etag                        = (known after apply)
      + full_name                   = (known after apply)
      + git_clone_url               = (known after apply)
      + html_url                    = (known after apply)
      + http_clone_url              = (known after apply)
      + id                          = (known after apply)
      + merge_commit_message        = "PR_TITLE"
      + merge_commit_title          = "MERGE_MESSAGE"
      + name                        = "example-project-1-repo"
      + node_id                     = (known after apply)
      + primary_language            = (known after apply)
      + private                     = (known after apply)
      + repo_id                     = (known after apply)
      + squash_merge_commit_message = "COMMIT_MESSAGES"
      + squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      + ssh_clone_url               = (known after apply)
      + svn_url                     = (known after apply)
      + topics                      = (known after apply)
      + visibility                  = "private"
      + web_commit_signoff_required = false

      + security_and_analysis (known after apply)
    }

  # github_team.team will be created
  + resource "github_team" "team" {
      + create_default_maintainer = false
      + description               = "example-project-1 team"
      + etag                      = (known after apply)
      + id                        = (known after apply)
      + members_count             = (known after apply)
      + name                      = "example-project-1-team"
      + node_id                   = (known after apply)
      + parent_team_read_id       = (known after apply)
      + parent_team_read_slug     = (known after apply)
      + privacy                   = "closed"
      + slug                      = (known after apply)
    }

  # github_team_membership.team-membership will be created
  + resource "github_team_membership" "team-membership" {
      + etag     = (known after apply)
      + id       = (known after apply)
      + role     = "maintainer"
      + team_id  = (known after apply)
      + username = "rocketstack-matt"
    }

  # github_team_repository.team-repo will be created
  + resource "github_team_repository" "team-repo" {
      + etag       = (known after apply)
      + id         = (known after apply)
      + permission = "pull"
      + repository = "example-project-1-repo"
      + team_id    = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 

```

* You can see in the summary that 5 objects would be created, none would be changed and none would be destroyed.
* Enter `yes` to have terraform apply the changes.
* Check in GitHub via the browser and you will see the new repository, team and the fact the team is setup as a maintainer on the repository.

### Making changes
You will notice that terrform has creted a `.terraform` directory and some lock files. This represents to terraform the state of the world as it knows it. You should therefore not make any changes to the resources terraform manages manually else this state will not be accurate.

If only a single person will be operating on the projects at a time you can check these files into source control. If a team based approach is needed you would need shared state managed in something like DynamoDB but that is beyond the scope of this project.

Let's see how terraform manages changes. Change the project-name variable and re-run `terraform apply`.

```json
variable organization {
  description = "Name of the Github Organization"
  type = string
  default = "YOUR-ORG"
}

variable "project_name" {
  description = "Name of the Project, no spaces"
  type = string
  default = "example-project-2"
}
```

You will see the following output:
```shell
github_team.team: Refreshing state... [id=10770819]
github_repository.repo: Refreshing state... [id=example-project-1-repo]
github_team_membership.team-membership: Refreshing state... [id=10770819:rocketstack-matt]
github_team_repository.team-repo: Refreshing state... [id=10770819:example-project-1-repo]
github_branch_protection.branch-protection: Refreshing state... [id=BPR_kwDOMkOzLs4DLqDZ]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # github_branch_protection.branch-protection must be replaced
-/+ resource "github_branch_protection" "branch-protection" {
      - force_push_bypassers            = [] -> null
      ~ id                              = "BPR_kwDOMkOzLs4DLqDZ" -> (known after apply)
      ~ repository_id                   = "example-project-1-repo" -> "example-project-2-repo" # forces replacement
        # (8 unchanged attributes hidden)

      ~ required_pull_request_reviews {
          - dismissal_restrictions          = [] -> null
          - pull_request_bypassers          = [] -> null
          - require_code_owner_reviews      = false -> null
            # (4 unchanged attributes hidden)
        }
    }

  # github_repository.repo will be updated in-place
  ~ resource "github_repository" "repo" {
      ~ full_name                   = "rocket-stack/example-project-1-repo" -> (known after apply)
        id                          = "example-project-1-repo"
      ~ name                        = "example-project-1-repo" -> "example-project-2-repo"
        # (34 unchanged attributes hidden)
    }

  # github_team.team will be updated in-place
  ~ resource "github_team" "team" {
      ~ description               = "example-project-1 team" -> "example-project-2 team"
        id                        = "10770819"
      ~ name                      = "example-project-1-team" -> "example-project-2-team"
      ~ slug                      = "example-project-1-team" -> (known after apply)
        # (9 unchanged attributes hidden)
    }

  # github_team_repository.team-repo must be replaced
-/+ resource "github_team_repository" "team-repo" {
      ~ etag       = "W/\"f7ae896c2e3995248b0e0f11d97b3f603a7add4acf7fb4d6af5ed42eff14e923\"" -> (known after apply)
      ~ id         = "10770819:example-project-1-repo" -> (known after apply)
      ~ repository = "example-project-1-repo" -> "example-project-2-repo" # forces replacement
        # (2 unchanged attributes hidden)
    }

Plan: 2 to add, 2 to change, 2 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

You can see here that because we use the project_name variable as a prefix to all resources, not just the repo name, terraform has worked out that it would need to change all affected resources resulting in 2 new resource, 2 changed resources and 2 destroyed resources.

Type `yes` to let it make the changes.

```shell
github_team_repository.team-repo: Destroying... [id=10770819:example-project-1-repo]
github_branch_protection.branch-protection: Destroying... [id=BPR_kwDOMkOzLs4DLqDZ]
github_team_repository.team-repo: Destruction complete after 0s
github_team.team: Modifying... [id=10770819]
github_branch_protection.branch-protection: Destruction complete after 1s
github_repository.repo: Modifying... [id=example-project-1-repo]
github_team.team: Modifications complete after 6s [id=10770819]
github_repository.repo: Modifications complete after 5s [id=example-project-2-repo]
github_team_repository.team-repo: Creating...
github_branch_protection.branch-protection: Creating...
github_team_repository.team-repo: Creation complete after 3s [id=10770819:example-project-2-repo]
github_branch_protection.branch-protection: Creation complete after 6s [id=BPR_kwDOMkOzLs4DLqEG]

Apply complete! Resources: 2 added, 2 changed, 2 destroyed.
```

If you check back in GitHub via the browser you will see the repo and team names have changed.

> **Warning!**  
> This also shows you that you cannot manage multiple teams with this simple setup. To create and manage multiple repositories and teams you should instead add additional configuration.
> 
> For a complex but safe setup, it is recommended you don't use the variables and create copies of the project-*.tf files to represent each project.

### Cleaning up
* Run `terraform destroy` and enter `yes` when prompted
* All of the created resources will be destroyed