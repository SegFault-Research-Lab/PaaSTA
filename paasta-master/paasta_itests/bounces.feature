Feature: Bounces work as expected

  Scenario: The upthendown bounce works
    Given a working paasta cluster
      And a new healthy app to be deployed
      And an old app to be destroyed

     When there are 2 old healthy tasks
      And deploy_service with bounce strategy "upthendown" and drain method "noop" is initiated
     Then the new app should be running
      And the old app should be running

     When there are 1 new healthy tasks
      And deploy_service with bounce strategy "upthendown" and drain method "noop" is initiated
     Then the new app should be running
      And the old app should be running

     When there are 2 new healthy tasks
      And deploy_service with bounce strategy "upthendown" and drain method "noop" is initiated
     When we wait a bit for the old app to disappear
     Then the old app should be gone

  Scenario: The upthendown bounce does not kill the old app if the new one is unhealthy
    Given a working paasta cluster
      And a new unhealthy app to be deployed
      And an old app to be destroyed

     When there are 2 old healthy tasks
      And deploy_service with bounce strategy "upthendown" and drain method "noop" is initiated
     Then the new app should be running
      And the old app should be running

     When there are 2 new unhealthy tasks
      And deploy_service with bounce strategy "upthendown" and drain method "noop" is initiated
     Then the old app should be configured to have 2 instances
      And the old app should be running

  Scenario: The brutal bounce works
    Given a working paasta cluster
      And a new healthy app to be deployed
      And an old app to be destroyed
     Then the old app should be running

     When there are 1 old healthy tasks
      And deploy_service with bounce strategy "brutal" and drain method "noop" is initiated
     Then the new app should be running
     When we wait a bit for the old app to disappear
     Then the old app should be gone

  Scenario: The crossover bounce works
    Given a working paasta cluster
      And a new healthy app to be deployed
      And an old app to be destroyed

     When there are 2 old healthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "noop" is initiated
     Then the new app should be running
      And the old app should be running

     When there are 1 new healthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "noop" is initiated
     Then the old app should be running
      And the old app should be configured to have 1 instances

     When there are 2 new healthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "noop" is initiated
      And we wait a bit for the old app to disappear
     Then the old app should be gone

  Scenario: The crossover bounce does not kill the old app if the new one is unhealthy
    Given a working paasta cluster
      And a new unhealthy app to be deployed
      And an old app to be destroyed

     When there are 2 old healthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "noop" is initiated
     Then the new app should be running
      And the old app should be running

     When there are 1 new unhealthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "noop" is initiated
     Then the old app should be configured to have 2 instances
      And the old app should be running

     When there are 2 new unhealthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "noop" is initiated
     Then the old app should be configured to have 2 instances
      And the old app should be running

  Scenario: The downthenup bounce works
    Given a working paasta cluster
      And a new healthy app to be deployed
      And an old app to be destroyed
     Then the old app should be running

     When there are 2 old healthy tasks
      And deploy_service with bounce strategy "downthenup" and drain method "noop" is initiated
     When we wait a bit for the new app to disappear
     Then the new app should be gone
     When we wait a bit for the old app to disappear
     Then the old app should be gone

     When deploy_service with bounce strategy "downthenup" and drain method "noop" is initiated
     Then the new app should be running

  Scenario: Bounces wait for drain method
    Given a working paasta cluster
      And a new healthy app to be deployed
      And an old app to be destroyed

     When there are 2 old healthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "test" is initiated
     Then the new app should be running
      And the old app should be running

     When there are 1 new healthy tasks
      And deploy_service with bounce strategy "crossover" and drain method "test" is initiated
     Then the new app should be running
      And the old app should be running
      # Note: this is different from the crossover bounce scenario because one of the old tasks is still draining.
      And the old app should be configured to have 2 instances

     When a task has drained
      And deploy_service with bounce strategy "crossover" and drain method "test" is initiated
     Then the old app should be configured to have 1 instances
