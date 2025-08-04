*** Settings ***
Documentation       Resource with all the S1 Platform URLs.
Library             Collections
Resource            Resources/Common/EnvironmentSetup/LoadEnvironmentData.resource
Variables           S1Platform/Common/EnvironmentURL.yaml


*** Variables ***
&{S1_URL_EXT}
...                 Login=/login
...                 Answer Security Questions=/login/answer-security-questions
...                 S1 Gateway=/gateway
...                 Accounts=/settings
...                 Account Settings=/settings
...                 Users=/settings/users
...                 Roles=/settings/roles
...                 Teams=/settings/teams


*** Keywords ***
Get S1 Platform Domain
    [Documentation]    Creates a domain based on environment.
    ...
    ...    Returns:
    ...    - (str): domain
    ...
    ${S1_PLATFORM_UI_URL}       Get From Dictionary     ${S1_PLATFORM_URL}          ${SOVOS_ENVIRONMENT}    ${NONE}
    ${domain}                   Get From Dictionary     ${S1_PLATFORM_UI_URL}       DOMAIN                  ${NONE}
    RETURN    ${domain}

Get S1 Platform UI URL
    [Documentation]    Creates a URL based on environment.
    ...
    ...
    ...    Returns:
    ...    - (str): url
    ...
    ${S1_PLATFORM_UI_URL}       Get From Dictionary     ${S1_PLATFORM_URL}          ${SOVOS_ENVIRONMENT}    ${NONE}
    ${url}                      Get From Dictionary     ${S1_PLATFORM_UI_URL}       URL                     ${NONE}
    ${port}                     Get From Dictionary     ${S1_PLATFORM_UI_URL}       NGINX_PORT              ${NONE}
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

Get S1 Platform UI URL With Extension
    [Documentation]    Creates a URL based on environment and extension.
    ...
    ...    Arguments:
    ...    - url_ext_name(str): defaults to [None]
    ...
    ...    Returns:
    ...    - (str): url with extension
    ...
    [Arguments]    ${url_ext_name}=${NONE}
    ${url}          Get S1 Platform UI URL
    ${url_ext}      Get From Dictionary         ${S1_URL_EXT}           ${url_ext_name}     ${NONE}
    ${s1_url}       Catenate                    SEPARATOR=${EMPTY}      ${url}              ${url_ext}
    RETURN    ${s1_url}
