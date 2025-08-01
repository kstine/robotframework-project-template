# Browser

Common resource folder for creating browsers and contexts using the Browser Library

## Files

*BrowserConfiguration.yaml* contains all the default settings for browsers and contexts

*ManageBrowser.resource* contains keywords for creating browsers and contexts with a few utility keywords.

## Examples

```robot
*** Settings ***
Documentation    How to use manage browser keywords
Suite Setup      Create Browser With Context
Test Setup       New Page


*** Test Cases ***
Google Test
    Go To    https://www.google.com

```

Notice that closing or quitting the page/context/browser is optional because Browser Library handles that by default.
