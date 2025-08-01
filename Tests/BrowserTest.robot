*** Settings ***
Documentation       Example of a basic Browser Library Test.
Resource            Resources/Common/Browser/Browser.resource
Suite Setup         Create Browser With Context
Suite Teardown      Quit Browser
Test Setup          New Page
Test Teardown       Quit Page


*** Test Cases ***
Browser Test
    [Documentation]    Simple Browser Test that takes a screenshot.
    Go To               https://www.google.com
    Take Screenshot
