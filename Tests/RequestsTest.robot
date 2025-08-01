*** Settings ***
Library     RequestsLibrary


*** Test Cases ***
Google Test
    GET                 https://www.google.com
    Status Should Be    ok
