*** Comments ***
RequestsTest.robot - REST API Testing Examples
This test suite demonstrates HTTP API testing using Robot Framework's RequestsLibrary.
It includes examples of both no session and session HTTP requests.
Test Coverage:
- Basic HTTP GET requests without session management
- HTTP requests using persistent sessions for better performance
- Session creation and cleanup patterns
- Status code validation


*** Settings ***
Documentation       Examples of Request Library Tests.
Resource            Resources/Common/RequestsLibrary/RequestsLibrary.resource
Resource            Resources/S1Platform/REST/Common/Session.resource
Test Tags           requests-example


*** Test Cases ***
S1 Platform Test > No Session
    [Documentation]    Typical example of a requests test.
    ...    Purpose: Demonstrates basic HTTP GET request without session management
    ...    Use Case: Simple one-off API calls where session persistence is not needed
    ...    Benefits: Simpler setup, no session cleanup required
    [Tags]    no-session
    ${s1_url}           Create S1 Session Url
    GET                 ${s1_url}
    Status Should Be    ok

S1 Platform Test > With Session
    [Documentation]    Typical example of a requests test leveraging a session.
    ...    Purpose: Demonstrates HTTP requests using persistent session management
    ...    Use Case: Multiple API calls to the same service, authentication handling
    ...    Benefits: Better performance, automatic cookie/session handling, connection reuse
    [Tags]    session
    [Setup]    Create S1 Session
    GET On Session      ${DEFAULT_ALIAS}        /
    [Teardown]    Delete All Sessions
