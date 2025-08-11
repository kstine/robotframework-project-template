# Selenium Library

Common resource folder for creating browsers using the Selenium Library

## Files

*SeleniumLibraryConfiguration.yaml* contains all the default settings for browsers

*ManageSeleniumLibrary.resource* contains keywords for creating browsers with a few utility keywords.

## Examples

```robot
*** Settings ***
Documentation    How to use manage Selenium browser keywords
Suite Setup      Create Selenium Browser Instance
Suite Teardown   Quit Selenium Browser


*** Test Cases ***
Google Test
    Go To    https://www.google.com

```
