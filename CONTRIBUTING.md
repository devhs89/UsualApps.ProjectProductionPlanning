# Contributing to Project Production Planning

Thank you for your interest in improving Project Production Planning.

This repository is proprietary software owned by UsualApps Inc. Before copying,
modifying, or submitting changes, you must obtain prior written authorization
from UsualApps Inc. as described in [LICENSE.md](LICENSE.md). Unsolicited pull
requests may be closed.

## Before You Start

- Read and follow the [Code of Conduct](CODE_OF_CONDUCT.md).
- For a substantial change, contact UsualApps or open an issue first so that the
  proposed behavior and scope can be agreed upon before implementation.
- Do not report security vulnerabilities in a public issue. Follow the private
  reporting instructions in [SECURITY.md](SECURITY.md).
- Keep each contribution focused on one bug, feature, or documentation change.

## Development Requirements

Application source is located in [`App`](App). To work on it, you need:

- Visual Studio Code with the Microsoft AL Language extension.
- Access to a Microsoft Dynamics 365 Business Central sandbox compatible with
  application version `27.0.0.0` and AL runtime `16.0`.
- Permission to contribute under the terms of this repository's proprietary
  license.

Open `project-production-planning.code-workspace` in Visual Studio Code. If
necessary, update the sandbox settings in `App/.vscode/launch.json` for your own
environment, then use **AL: Download Symbols** before building the project.
Environment-specific launch settings should not be committed.

## Making a Change

1. Create a branch from the latest `main` branch.
2. Make the smallest change that completely addresses the issue.
3. Build the extension with **AL: Package**.
4. Publish it to a compatible sandbox and test the affected user flow.
5. Update documentation when behavior, configuration, or extension points
   change.
6. Open a pull request against `main`.

### AL Conventions

- Use object IDs in the assigned range `71826200..71826299`.
- Apply the mandatory `UAS` suffix defined in `App/AppSourceCop.json`.
- Follow the configured namespace template, `UsualApps.$(parentfolder)`.
- Keep `NoImplicitWith` compatibility and address compiler and code-analysis
  warnings introduced by your change.
- Prefer standard Business Central behavior and records over duplicating
  platform functionality.
- Add or update automated tests when practical. Where automated coverage is not
  available, include clear manual test steps in the pull request.
- Do not commit generated packages, downloaded symbols, snapshots, caches, or
  other files excluded by `.gitignore`.

## AL-Go Files

The files under `.AL-Go/` and `.github/` contain AL-Go template configuration
and automation. Change them only when the contribution specifically concerns
the build or release infrastructure. Application changes belong under `App/`.

## Pull Request Checklist

Before requesting review, confirm that:

- The pull request explains the problem, the solution, and any user-visible
  impact.
- Related issues are linked.
- The extension builds successfully.
- Relevant automated or manual tests pass, with test evidence included.
- New objects use the assigned ID range, namespace, and mandatory suffix.
- Documentation and translations are updated where applicable.
- No credentials, license files, customer data, generated `.app` packages, or
  environment-specific settings are included.
- The AL-Go pull request checks pass.

Pull requests are reviewed by the repository owner. Review feedback may require
additional changes before a contribution can be accepted.
