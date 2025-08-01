*** Settings ***
Library     Browser


*** Test Cases ***
Browser Test
    New Browser
    New Page            https://www.google.com
    Take Screenshot
