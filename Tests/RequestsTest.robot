*** Settings ***
Documentation       Examples of Request Library Tests.
Resource            Resources/Common/RequestsLibrary/RequestsLibrary.resource


*** Test Cases ***
Google Test > No Session
    [Documentation]    Typical example of a requests test.
    GET                 https://www.google.com
    Status Should Be    ok

Google Test > With Session
    [Documentation]    Typical example of a requests test leveraging a session.
    [Setup]    Create Session    google    https://www.google.com
    GET On Session      google                  /
    [Teardown]    Delete All Sessions
