# Windows Server roles

## Identify the role

Open Server Manager and record whether the system is standalone, a domain member, or a domain controller. List installed roles, dependent clients and the expected ports or shares.

## Domain accounts and policies

On a domain controller use Active Directory Users and Computers for domain identities. Review delegated groups and service identities before editing membership. Use Group Policy Management and a resultant policy report to identify where settings actually come from. Keep changes scoped to the intended policy and organizational unit.

## Verify the role

Check DNS name resolution from an authorized client, test approved domain authentication when required and review role logs. For IIS or file services, check the intended site or share as the intended user. Record the policy or setting you changed and use the same client check after rollback.
