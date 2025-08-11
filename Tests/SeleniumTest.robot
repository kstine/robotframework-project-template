*** Comments ***
SeleniumTest.robot - Selenium Testing Examples
This test suite demonstrates Selenium testing using Robot Framework's SeleniumLibrary.


*** Settings ***
Documentation       Example of a basic Selenium Test.
Resource            Resources/Common/SUTSeleniumLibrary/ManageSeleniumLibrary.resource
Resource            Resources/S1Platform/UI/Common/S1UrlMap.resource
Test Tags           selenium-example
Suite Setup         Suite Setup Keywords
Suite Teardown      Suite Teardown Keywords


*** Variables ***
${S1_URL_SUITE}     ${EMPTY}    # Suite Variable


*** Test Cases ***
Selenium Test
    [Documentation]    Simple Selenium Test that takes a screenshot.
    ...    Purpose: Demonstrates basic Selenium test.
    ...    Use Case: Simple Selenium test that takes a screenshot.
    ...    Benefits: Simpler setup, no session cleanup required
    [Tags]    selenium
    Go To                       ${S1_URL_SUITE}
    Capture Page Screenshot


*** Keywords ***
Suite Setup Keywords
    [Documentation]    Suite Setup Keywords.
    ${s1_url}                           Get S1 Platform UI URL
    # robocop: off=replace-set-variable-with-var
    Set Suite Variable                  ${S1_URL_SUITE}             ${s1_url}
    Create Selenium Browser Instance

Suite Teardown Keywords
    [Documentation]    Suite Teardown Keywords.
    Quit Selenium Browser
