*** Settings ***
Documentation       Load environment specific global configurations
...                 Current Sovos Environments:
...                 Lower: INT, QA
...                 Upper: PRD, UAT, STG
...
...                 The variables in this file can be overwritten from the commandline.
...


*** Variables ***
${SOVOS_ENVIRONMENT}    QA


*** Keywords ***
Load Test Environment Configurations
    [Documentation]    None
    Log     This may be needed for other configs.
