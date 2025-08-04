*** Settings ***
Documentation       Examples of Request Library Tests.
Resource            Resources/Common/RequestsLibrary/RequestsLibrary.resource
Resource            Resources/S1Platform/REST/Common/Session.resource


*** Test Cases ***
Google Test > No Session
    [Documentation]    Typical example of a requests test.
    ${s1_url}           Create S1 Session Url
    GET                 ${s1_url}
    Status Should Be    ok

Google Test > With Session
    [Documentation]    Typical example of a requests test leveraging a session.
    [Setup]    Create S1 Session
    GET On Session      ${DEFAULT_ALIAS}        /
    [Teardown]    Delete All Sessions
