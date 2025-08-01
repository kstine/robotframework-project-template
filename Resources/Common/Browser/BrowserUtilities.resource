*** Settings ***
Documentation       Utility Keywords that use Browser Library
Library             Collections
Resource            Browser.resource


*** Keywords ***
Get List Of Texts
    [Documentation]    Returns a list of text from the given locator
    ...
    ...    Arguments:
    ...    - locator(str):required
    ...    - filter_empty(str): defaults to [FALSE]
    ...
    ...    Returns:
    ...    - (list[str]): list of texts
    ...
    [Arguments]    ${locator}    ${filter_empty}=${FALSE}
    ${elements}         Get Elements    ${locator}
    ${texts}            Create List
    FOR    ${elem}    IN    @{elements}
        TRY
            ${text}             Get Text    ${elem}
            Append To List      ${texts}    ${text}
        EXCEPT    AS    ${error}
            Log     ${error}    WARN
        END
    END
    IF    ${filter_empty}
        ${texts}    Evaluate    [text for text in $texts if text]
    END
    RETURN    ${texts}

Drag And Drop Using Mouse Move
    [Documentation]    This is an option if time is needed between Mouse Move/Mouse Button Steps
    ...    Especially when the Drag And Drop By Coordinates Browser keyword is too fast.
    [Arguments]    ${from_x}    ${from_y}    ${to_x}    ${to_y}    ${time_delta}=256ms
    Mouse Move      ${from_x}           ${from_y}       steps=1
    Sleep           ${time_delta}
    Mouse Button    down
    Sleep           ${time_delta}
    Mouse Move      ${to_x}             ${to_y}         steps=1
    Sleep           ${time_delta}
    Mouse Button    up

Try To Scroll To Last Row
    [Documentation]    Makes an effort to scroll to the last row.
    ...
    ...    Arguments:
    ...    - row_locator (str): required
    ...    - scrolls (str): Defaults to [1]
    [Arguments]    ${row_locator}    ${scrolls}=1
    FOR    ${i}    IN RANGE    ${scrolls}
        Log                     Scrolls: ${i}
        ${elements}             Get Elements        ${row_locator}
        TRY
            ${element}              Get From List       ${elements}     -1
            Scroll To Element       ${element}
        EXCEPT
            BREAK
        END
    END

Custom URL Wait
    [Documentation]    Attempts to wait for a URL in two different ways:
    ...     First exact match of url,
    ...     Then retries with contains.
    ...
    ...    Arguments:
    ...    - url(str): required
    ...
    ...    Asserts:
    ...    Wait For Condition
    ...
    [Arguments]   ${url}
    TRY
        Wait For Condition      URL                             ==      ${url}
        ...                     timeout=10
    EXCEPT    AS    ${error}
        Log                     ${error}: Trying again...       WARN
        Wait For Condition      URL                             *=      ${url}    # robocop: off=undefined-argument-value
    END
