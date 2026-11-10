# Getting started and glossary

## Read the brief

Extract approved users and administrators, required software, services, explicit policy settings and prohibited actions. If the brief is silent, record the uncertainty before changing a dependency.

## Read-only tools

In PowerShell start with Get-Help, Get-Service and Get-LocalUser where available. In a Unix shell start with man, pwd, ls and id. Read output before using a pipeline and check whether a tool changes state before elevating.

## Glossary

Baseline: recorded starting state. Effective policy: settings actually applied after precedence. Least privilege: grant only the access needed. Dependency: a service or resource another feature requires. Rollback: restoring the prior state after a change causes trouble.
