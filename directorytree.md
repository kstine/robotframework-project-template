# Directory Tree

```text
robot-template/
├── AzurePipelines/
│   ├── azure_pipelines.md
│   ├── robot-automation-pipeline.yaml
│   └── templates/
│       ├── jobs/
│       │   ├── jobs.md
│       │   └── robot-automation-pipeline-jobs.yaml
│       ├── stages/
│       │   └── stages.md
│       ├── steps/
│       │   ├── acr_login.yaml
│       │   ├── acr_logout_steps.yaml
│       │   ├── acr_pull_steps.yaml
│       │   ├── publish_results_steps.yaml
│       │   ├── run_tests_steps.yaml
│       │   ├── setup_directories_steps.yaml
│       │   └── steps.md
│       ├── templates.md
│       └── variables/
│           ├── acr-variables.yaml
│           ├── smoke-groups-variables.yaml
│           └── variables.md
├── common-robot-docker-compose.yaml
├── CustomLibraries/
│   ├── CommonLibrary/
│   │   ├── __init__.py
│   │   └── common_library.py
│   └── customlibraries.md
├── Data/
│   ├── ArgumentsFiles/
│   │   ├── argumentsfiles.md
│   │   ├── Common/
│   │   │   ├── ArgumentsTemplateFile.robot
│   │   │   ├── CommonArguments.robot
│   │   │   ├── DryRunProject.robot
│   │   │   ├── PythonPathArguments.robot
│   │   │   └── RunAllExamples.robot
│   │   └── Local/
│   └── data.md
├── docker-compose.s1-platform-automation.local.yaml
├── docker-compose.s1-platform-automation.yaml
├── Downloads/
├── poetry.lock
├── pyproject.toml
├── README.md
├── Resources/
│   ├── Common/
│   │   ├── Browser/
│   │   │   ├── browser_resource_version.py
│   │   │   ├── Browser.md
│   │   │   ├── Browser.resource
│   │   │   ├── BrowserConfiguration.yaml
│   │   │   ├── BrowserUtilities.resource
│   │   │   ├── BrowserUtilitiesPlugin.py
│   │   │   └── ManageBrowser.resource
│   │   ├── common.md
│   │   ├── EnvironmentSetup/
│   │   │   ├── environmentsetup.md
│   │   │   └── LoadEnvironmentData.resource
│   │   └── RequestsLibrary/
│   │       ├── GetSessionData.py
│   │       ├── ManageRequestsLibrary.resource
│   │       ├── requests_resource_version.py
│   │       ├── RequestsContextUtility.py
│   │       ├── RequestsLibrary.md
│   │       ├── RequestsLibrary.resource
│   │       └── set_urllib3.py
│   ├── resources.md
│   ├── S1Platform/
│   │   ├── Common/
│   │   │   └── EnvironmentURL.yaml
│   │   ├── REST/
│   │   │   └── Common/
│   │   │       └── Session.resource
│   │   ├── s1platform.md
│   │   └── UI/
│   │       ├── Common/
│   │       │   └── S1UrlMap.resource
│   │       └── s1uicommon.md
│   ├── SolutionOne/
│   │   └── solutionone.md
│   └── Utilities/
│       └── utilities.md
├── Results/
│   └── results.md
├── robocop.toml
├── robot.toml
├── Scripts/
│   ├── run_tests.ps1
│   ├── verify_node_installation.py
│   ├── verify_poetry_installation.py
│   ├── verify_python_installation.bat
│   └── verify_python_installation.ps1
├── Tasks/
│   └── tasks.md
└── Tests/
    ├── BrowserTest.robot
    ├── KeywordAcceptanceTests/
    │   ├── CommonLibraryTest.robot
    │   ├── expected_config.json
    │   └── test_data.json
    ├── RequestsTest.robot
    └── tests.md
```
