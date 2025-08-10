import jenkins.model.*
import hudson.security.*
import jenkins.install.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.*

// Force setup completion
def instance = Jenkins.get()
if(!instance.installState.isSetupComplete()) {
  InstallUtil.proceedToNextStateFrom(InstallState.INITIAL_SETUP_COMPLETED)
}

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

// Set permissions
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

// Configure Jenkins URL
import jenkins.model.JenkinsLocationConfiguration
def jlc = JenkinsLocationConfiguration.get()
jlc.setUrl(System.getenv("JENKINS_URL"))
jlc.save()

// Create pipeline job
def pipelineJob = Jenkins.instance.createProject(WorkflowJob, 'tech-nova-pipeline')
pipelineJob.definition = new CpsScmFlowDefinition(
  new GitSCM(
    gitTool: 'Default',
    userRemoteConfigs: [[
      url: 'https://github.com/FrothyRythm/project010.git',
      credentialsId: 'github-access-token'
    ]],
    branches: [[name: '*/main']]
  ),
  'Jenkinsfile'
)
pipelineJob.save()

// Save all changes
instance.save()