# Security Policy

## Supported Versions

Below are the versions of the OpenTelemetry API for Dart that are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.8.x   | :white_check_mark: |
| < 0.8.0 | :x:                |

## Reporting a Vulnerability

We take the security of OpenTelemetry API for Dart seriously. If you believe you have found a security vulnerability, please follow these steps:

1. **Do not disclose the vulnerability publicly**
2. **Contact the maintainers privately** - Email security@dartastic.io with details of the vulnerability
3. **Provide sufficient information** to reproduce the issue, including:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested mitigation if available

## What to Expect

After you report a vulnerability:

1. **Acknowledgment** - You will receive acknowledgment of your report within 48 hours
2. **Verification** - Our team will work to verify the vulnerability
3. **Remediation Plan** - We will develop a plan to address the vulnerability
4. **Public Disclosure** - Once a fix is available, we will coordinate with you on public disclosure

## Security Best Practices

When using OpenTelemetry API for Dart:

1. Keep the package updated to the latest supported version
2. Review your telemetry data to ensure sensitive information is not inadvertently collected
3. Apply appropriate access controls to your telemetry data collection endpoints
4. Consider using TLS for all telemetry data transmission

## Security Considerations for Telemetry Data

When implementing OpenTelemetry:

1. **Data Minimization** - Only collect the telemetry data necessary for your use case
2. **PII Protection** - Avoid including personally identifiable information in spans or metrics
3. **Sensitive Data** - Avoid including sensitive information such as authentication tokens in attributes

## Disclosure Policy

Our disclosure policy is:

1. Security issues will be announced via GitHub security advisories
2. CVEs will be requested when appropriate
3. Fixed versions will be clearly identified in release notes
