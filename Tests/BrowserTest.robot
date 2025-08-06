*** Comments ***
BrowserTest.robot - Browser Testing Examples
This test suite demonstrates browser testing using Robot Framework's BrowserLibrary.
It includes examples of both no session and session HTTP requests.


*** Settings ***
Documentation       Example of a basic Browser Library Test.
Resource            Resources/Common/Browser/Browser.resource
Resource            Resources/S1Platform/UI/Common/S1UrlMap.resource
Test Tags           browser-example
Suite Setup         Suite Setup Keywords
Suite Teardown      Suite Teardown Keywords
Test Setup          Test Setup Keywords
Test Teardown       Test Teardown Keywords


*** Variables ***
${S1_URL_SUITE}     ${EMPTY}    # Suite Variable


*** Test Cases ***
Browser Test
    [Documentation]    Simple Browser Test that takes a screenshot.
    ...    Purpose: Demonstrates basic browser test.
    ...    Use Case: Simple browser test that takes a screenshot.
    ...    Benefits: Simpler setup, no session cleanup required
    [Tags]    browser
    Go To               ${S1_URL_SUITE}
    Take Screenshot


*** Keywords ***
Suite Setup Keywords
    [Documentation]    Suite Setup Keywords.
    ${s1_url}                       Get S1 Platform UI URL
    Set Suite Variable              ${S1_URL_SUITE}             ${s1_url}  # robocop: off=replace-set-variable-with-var
    Create Browser With Context

Suite Teardown Keywords
    [Documentation]    Suite Teardown Keywords.
    Quit Browser

Test Setup Keywords
    [Documentation]    Test Setup Keywords.
    New Page

Test Teardown Keywords
    [Documentation]    Test Teardown Keywords.
    Quit Page
