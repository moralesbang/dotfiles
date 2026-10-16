# Bump automation

How a dependency PR turns into bump PRs in `humand-backoffice` and `humand-web`.

## Dependency PRs

Each one branches from its repository's `main` and targets `main`; a change spanning `hu-translations` and `material-hu` uses one branch name in both. Its release label, spelled by `work-git-pr`, sets how far the change travels.

## Bump targets

Once a dependency PR merges, `app/humand-react-bot` opens a bump PR per target in each consumer:

| dependency PR label | consumer bump targets |
|---|---|
| none | `develop` |
| `bugfix` | `develop`, staging |
| `hotfix` | `develop`, staging, production |

Staging and production are the date-named release branches (`release-YYYY.MM.DD`) the automation picks; take their names from the bump PRs. A `release-*` base receives the change only from a dependency PR labeled `bugfix` or `hotfix`: with neither label, hand off to the user.
