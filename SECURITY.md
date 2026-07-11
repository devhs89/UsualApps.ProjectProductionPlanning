# Security Policy

UsualApps Inc. takes the security of Project Production Planning seriously. We
appreciate responsible reports that help us protect Business Central customers
and their data.

## Supported Versions

Security fixes are provided for the latest released version when a fix is
appropriate. Older versions may require an upgrade to receive a security fix.

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| Older releases | No |

## Reporting a Vulnerability

Do not disclose a suspected vulnerability in a public GitHub issue, discussion,
pull request, or other public channel.

Use one of these private reporting methods:

1. Use the repository's **Security** tab and select **Report a vulnerability**
   to open a private vulnerability report, if that option is available.
2. Otherwise, contact UsualApps through the
   [UsualApps contact form](https://usualapps.com/contact/) and state that you
   need to report a security vulnerability in **Project Production Planning**.
   Do not include exploit code, credentials, personal data, or other sensitive
   details in the initial message. We will arrange an appropriate private
   channel for the full report.

Include as much of the following information as possible:

- A clear description of the vulnerability and its potential impact.
- The affected version, commit, object, and file location.
- Required Business Central version, configuration, permissions, and
  prerequisites.
- Reproduction steps or a minimal proof of concept.
- Relevant logs or screenshots with credentials, customer information, and
  other sensitive data removed.
- Any known mitigations or workarounds.
- Your preferred contact details and whether you want public acknowledgment.

We aim to acknowledge a complete report within five business days. We will
investigate, assess its impact, and provide status updates when practical.
Remediation timing depends on severity, complexity, platform dependencies, and
release requirements. Please allow us a reasonable opportunity to investigate
and address the issue before public disclosure.

## Scope

This policy covers vulnerabilities in the Project Production Planning
application and repository-specific configuration maintained by UsualApps Inc.

The repository uses Microsoft's AL-Go for GitHub tooling. If a vulnerability is
in AL-Go, an AL-Go Action, or another third-party dependency rather than this
repository's code or configuration, report it privately to that project's
maintainer under its security policy. You may also notify UsualApps privately if
the vulnerability affects this repository.

### Microsoft and AL-Go Security Issues

For vulnerabilities originating in Microsoft-maintained AL-Go tooling, use the
applicable Microsoft resource:

- Review the source and project information in the
  [Microsoft AL-Go repository](https://github.com/microsoft/AL-Go).
- Submit a confidential report through the
  [Microsoft Security Response Center](https://msrc.microsoft.com/create-report).
- If you cannot use the submission portal, contact
  [secure@microsoft.com](mailto:secure@microsoft.com).
- Use the [MSRC public PGP key](https://www.microsoft.com/en-us/msrc/pgp-key)
  when encrypted email is appropriate.
- Review Microsoft's
  [Coordinated Vulnerability Disclosure guidance](https://www.microsoft.com/en-us/msrc/cvd)
  before publicly disclosing a Microsoft vulnerability.

Do not send vulnerabilities in UsualApps application code to Microsoft. Report
those to UsualApps using the private methods described above.

Security reports are not a support channel for ordinary defects, feature
requests, configuration assistance, or questions without a security impact.

## Responsible Research

- Do not access, modify, retain, or disclose data that does not belong to you.
- Do not test against production systems or other people's environments.
- Do not perform denial-of-service, social-engineering, phishing, spam, or
  destructive testing.
- Stop testing and report the issue immediately if you encounter sensitive or
  personal data.
- Keep vulnerability details confidential until UsualApps has addressed the
  issue or agreed to a disclosure plan.

This policy does not grant a license to the software or authorization to test
systems owned or operated by UsualApps Inc. or any third party. Obtain prior
written authorization before conducting security testing. See
[LICENSE.md](LICENSE.md) for the repository's license terms.
