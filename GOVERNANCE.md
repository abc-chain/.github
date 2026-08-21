# Governance and change control

The owner-controlled `platform` team reviews organization repository defaults,
reusable workflows, templates, custom-property definitions, and ruleset
recipes. General engineering access belongs in separate product teams.

Only `2systemadmin`, the current organization owner, may create, edit, delete,
or bypass live rulesets. Its bypass is user-specific and pull-request-only;
membership in `platform` does not grant ruleset administration or bypass.

Policy changes should:

1. describe the protected risk and affected repository classes;
2. include migration and rollback instructions;
3. be tested in the template or a representative repository;
4. avoid requiring a status check until it has run successfully with a stable,
   unique name;
5. use a staged rollout and record any time-bounded exception.

Ruleset bypass is a break-glass mechanism, not a normal merge method. After a
bypass, document why it was necessary, the actor, affected change, and follow-up.

Before enabling independent review or Code Owner requirements, maintain at least
two eligible human reviewers and verify that named teams exist, are visible, and
have write access to each protected repository.
