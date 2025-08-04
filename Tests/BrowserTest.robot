*** Settings ***
Documentation       Example of a basic Browser Library Test.
Resource            Resources/Common/Browser/Browser.resource
Resource            Resources/S1Platform/UI/Common/S1UrlMap.resource
Suite Setup         Create Browser With Context
Suite Teardown      Quit Browser
Test Setup          New Page
Test Teardown       Quit Page


*** Test Cases ***
Browser Test
    [Documentation]    Simple Browser Test that takes a screenshot.
    ${s1_url}           Get S1 Platform UI URL
    Go To               ${s1_url}
    Take Screenshot
