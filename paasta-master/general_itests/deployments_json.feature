Feature: Per-Service Deployments.json can be written and read back

    Scenario: Per-Service Deployments.json can be written and read back
        Given a test git repo is setup with commits
        When we generate deployments.json for that service
        Then that deployments.json can be read back correctly
