# CyberPatriot Image Round Workflow

Use this sequence for each image. Follow the current round instructions and coach guidance whenever they differ from this general workflow.

## 1. Read and establish constraints

- Read the complete image instructions before changing the system.
- Note the operating system, required users, required services, scoring tasks, prohibited actions, and time limit.
- Confirm what counts as an authorized change and which tools or external resources are allowed.
- Identify any details that must not be shared outside the team.

## 2. Establish a baseline

- Confirm the image is running and identify its hostname, OS version, and available disks or partitions.
- Review the scoring interface and record the starting score or status.
- Inspect the instructions for required services, applications, accounts, and files.
- Take a team-approved baseline snapshot or notes if the platform permits it.

## 3. Triage before changing settings

Prioritize findings by impact, confidence, and time:

1. Clear violations explicitly identified by the image instructions.
2. High-confidence account, password, or access-control issues.
3. High-confidence security configuration issues that do not conflict with required functionality.
4. Less certain findings that need more investigation.

For each candidate change, state the evidence, expected benefit, risk to required functionality, and verification method. If the evidence is unclear, investigate first or ask the team lead.

## 4. Make controlled changes

- Change one related setting or small group at a time.
- Assign one person to make a change and another to review it when practical.
- Preserve required accounts, services, software, and files.
- Avoid broad cleanup, bulk scripts, or unreviewed commands.
- Record the original state when practical, the change, the reason, the owner, and the result.

## 5. Verify after each change

- Confirm the setting or account state changed as intended.
- Confirm dependent services and required applications still work.
- Recheck the score or task status.
- If the change causes a problem, use the team’s documented recovery approach and tell the team lead.

## 6. Final review and handoff

- Re-read the image instructions and review each requirement.
- Recheck scoring, required services, and access for authorized users.
- Stop making speculative changes near the deadline.
- Report unresolved risks and completed work to the team lead.
- After the round, record lessons learned without secrets or competition-protected content.
