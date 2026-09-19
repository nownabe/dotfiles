# `gh list-run-jobs`

List jobs from a GitHub Actions workflow run, with each job's steps and URL. One call answers "which job failed, at which step" without a follow-up `gh api` on the job.

## Usage

```bash
claude-tools gh list-run-jobs <run_id> [--repo <owner/repo>]
```

## Arguments

| Argument              | Required | Description                                                                |
| --------------------- | -------- | -------------------------------------------------------------------------- |
| `run_id`              | Yes      | The workflow run ID to list jobs for                                       |
| `--repo <owner/repo>` | No       | Target repository. If omitted, detected from the current working directory |

## Output

Returns a JSON array of objects with the following fields:

| Field        | Description                                          |
| ------------ | ---------------------------------------------------- |
| `name`       | Job name                                             |
| `conclusion` | Job result (`success`, `failure`, `cancelled`, etc.) |
| `id`         | Job ID (pass to `gh get-job-logs`)                   |
| `url`        | Job page on github.com                               |
| `steps`      | Array of `{name, conclusion}` in execution order     |

## Examples

```bash
# List all jobs in a workflow run
claude-tools gh list-run-jobs 12345678

# List jobs from a specific repository
claude-tools gh list-run-jobs 12345678 --repo myorg/myrepo

# Inspect one job: its result, failed steps and URL
claude-tools gh list-run-jobs 12345678 | jq '.[] | select(.name == "Deploy")'

# Only the failed steps across all jobs
claude-tools gh list-run-jobs 12345678 | jq '.[] | {name, failed: [.steps[] | select(.conclusion == "failure").name]}'
```
