*** Settings ***
Documentation       Session resource for connecting to S1 REST API Services.
Library             Collections
Resource            Resources/Common/EnvironmentSetup/LoadEnvironmentData.resource
Resource            Resources/Common/RequestsLibrary/RequestsLibrary.resource
Variables           S1Platform/Common/EnvironmentURL.yaml


*** Variables ***
&{BASE_HEADER_SETTINGS}
...                         Content-Type=application/json
...                         Accept=*/*
${DEFAULT_ALIAS}            s1-alias


*** Keywords ***
Create S1 Session
    [Documentation]
    ...    Args:
    ...    - alias (str): Default[{DEFAULT_ALIAS}]
    ...    - s1_url (str): defaults to [NONE]
    ...    - max_retries (int): defaults to [3]
    ...    - headers (dict): defaults to [BASE_HEADER_SETTINGS]
    ...
    [Arguments]    ${alias}=${DEFAULT_ALIAS}
    ...    ${s1_url}=${NONE}
    ...    ${max_retries}=3
    ...    ${headers}=${BASE_HEADER_SETTINGS}
    IF    $s1_url is None
        ${s1_url}       Create S1 Session Url
    END
    Create Session    ${alias}    ${s1_url}    headers=${headers}    disable_warnings=${TRUE}
    ...               max_retries=${max_retries}
    IF    $SOVOS_ENVIRONMENT in ['INT', 'UAT', 'STG', 'PRD']
        Mount Context On Session    ${alias}    ${s1_url}
    END

Create S1 Session Url
    [Documentation]    Creates a S1 Session URL string
    ...
    ...    Returns:
    ...    - (str): s1 url
    ...
    ${s1_platform_url_data}     Get From Dictionary     ${S1_PLATFORM_URL}          ${SOVOS_ENVIRONMENT}    ${NONE}
    ${url}                      Get From Dictionary     ${s1_platform_url_data}     URL                     ${NONE}
    ${port}                     Get From Dictionary     ${s1_platform_url_data}     NGINX_PORT              ${NONE}
    IF    $port is None
        ${s1_url}       Catenate
        ...             SEPARATOR=${EMPTY}
        ...             ${url}
    ELSE
        ${s1_url}       Catenate
        ...             SEPARATOR=${EMPTY}
        ...             ${url}
        ...             :
        ...             ${port}
    END
    RETURN    ${s1_url}

Update X Request Context
    [Documentation]    Adds or updates the x-request-context of the session
    ...
    ...    Arguments:
    ...    - alias(str): required
    ...    - x_request_context(str): required
    ...
    [Arguments]    ${alias}    ${x_request_context}
    # robocop: off=replace-set-variable-with-var
    Set Local Variable      &{context_header}       x-request-context=${x_request_context}
    Update Session          ${alias}                headers=${context_header}
