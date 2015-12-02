##Updating config variables per agent.

- Run the following as 'teamcity' user.
- Teamcity is installed in `/opt/TeamCity/`
- Agent configuration can be found in `/opt/TeamCity/buildAgent*/conf`

To edit config variables for `agent1` :

- Edit `/opt/TeamCity/buildAgent/conf/buildAgent.properties` 
  
  To add a variable to ENV, set it as : 
  ```
  # Environment Variables
  #env.exampleEnvVar=example Env Value
  env.GROCER_PORT=2196
  ```
  
- Restart the agent : 
  ```
    /opt/TeamCity/buildAgent/bin/agent.sh stop
    /opt/TeamCity/buildAgent/bin/agent.sh start
  ```
