*** Settings ***
Documentation       Keyword file to contain Browser Library common keywords
Library             Collections
Library             OperatingSystem
Library             Browser    plugins=${CURDIR}${/}BrowserUtilitiesPlugin.py
Variables           BrowserConfiguration.yaml


*** Variables ***
@{WEB_BROWSER_PERMISSIONS}      clipboard-read                      clipboard-write
&{WEB_BROWSER_ARGUMENTS}
...                             browser=${WEB_BROWSER}
...                             headless=${BROWSER_IS_HEADLESS}
&{CONTEXT_ARGUMENTS}            viewport=${NONE}
${USER_DATA_DIRECTORY}          ${NONE}


*** Keywords ***
Set Chrome Arguments
    [Documentation]    Passes in the arguments for chrome command line tool.
    Set To Dictionary       ${WEB_BROWSER_ARGUMENTS}    args=${CHROME_ARGS}

Clean Local Download Folder
    [Documentation]    Clears all files from the Download Folder.
    TRY
        Directory Should Exist      ${WEB_BROWSER_DOWNLOAD_PATH}
        Empty Directory             ${WEB_BROWSER_DOWNLOAD_PATH}
    EXCEPT    AS    ${error}
        Log     ${error}            ERROR
        Log     Doing nothing.      INFO
    END

Configure Download Path
    [Documentation]    Creates a default path to download files from the web browser.
    ...    Currently set to the Downloads folder.
    ...
    ...    Returns:
    ...    - WEB_BROWSER_DOWNLOAD_PATH (str): SUITE
    ...
    TRY
        Variable Should Exist       ${WEB_BROWSER_DOWNLOAD_PATH}
    EXCEPT
        ${path}                 Join Path                       ${EXECDIR}      Downloads
        Set Suite Variable      ${WEB_BROWSER_DOWNLOAD_PATH}    ${path}
    END
    Log                         Download Folder: ${WEB_BROWSER_DOWNLOAD_PATH}       INFO

Create Browser With Context
    [Documentation]    Opens a browser with context based on BROWSER_STRATEGY.
    ...    Valid values: incognito, persistent, debug
    Log                                         \nBrowser Strategy: ${BROWSER_STRATEGY}     CONSOLE
    Configure Download Path
    Create Local Download Directory
    IF    '${BROWSER_STRATEGY}'=='incognito'
        Create Incognito Browser And Context
    ELSE IF    '${BROWSER_STRATEGY}'=='persistent'
        Create Persistent Browser And Context
    ELSE IF    '${BROWSER_STRATEGY}'=='debug'
        Create Debug Browser And Context
    ELSE
        Create Incognito Browser And Context
    END
    Set Browser Timeout                         ${BROWSER_TIMEOUT}

Create Debug Browser And Context
    [Documentation]    Creates a new browser and context for demo purposes only.
    ...    Will not be able to download files.
    ${display_resolution_values}    Get Display Resolution Values
    Set To Dictionary               ${CONTEXT_ARGUMENTS}
    ...                             viewport=${display_resolution_values}
    ...                             permissions=${WEB_BROWSER_PERMISSIONS}
    Open Browser                    &{WEB_BROWSER_ARGUMENTS}
    New Context                     &{CONTEXT_ARGUMENTS}

Create Incognito Browser And Context
    [Documentation]    Creates a new browser and context using a clean incognito browser.
    ${display_resolution_values}    Get Display Resolution Values
    IF    '${WEB_BROWSER}' == 'chromium'    Set Chrome Arguments
    Set To Dictionary       ${WEB_BROWSER_ARGUMENTS}
    ...                     downloadsPath=${WEB_BROWSER_DOWNLOAD_PATH}
    Set To Dictionary       ${CONTEXT_ARGUMENTS}
    ...                     acceptDownloads=True
    ...                     viewport=${display_resolution_values}
    ...                     permissions=${WEB_BROWSER_PERMISSIONS}
    New Browser             &{WEB_BROWSER_ARGUMENTS}
    New Context             &{CONTEXT_ARGUMENTS}

Create Local Download Directory
    [Documentation]    Creates Directory if it does not exist.
    Create Directory    ${WEB_BROWSER_DOWNLOAD_PATH}

Create Persistent Browser And Context
    [Documentation]    Creates a new browser and context for production environments.
    ${display_resolution_values}        Get Display Resolution Values
    Set User Data Directory Variable
    IF    '${WEB_BROWSER}' == 'chromium'    Set Chrome Arguments
    Set To Dictionary       ${WEB_BROWSER_ARGUMENTS}
    ...                     userDataDir=${USER_DATA_DIRECTORY}
    ...                     downloadsPath=${WEB_BROWSER_DOWNLOAD_PATH}
    Set To Dictionary       ${CONTEXT_ARGUMENTS}
    ...                     acceptDownloads=True
    ...                     viewport=${display_resolution_values}
    ...                     permissions=${WEB_BROWSER_PERMISSIONS}
    New Persistent Context    &{WEB_BROWSER_ARGUMENTS}    &{CONTEXT_ARGUMENTS}

Get Display Resolution Values
    [Documentation]    Gets the resolution values from the browser configurations
    [Tags]    robot:private
    ${display_resolution_values}    Get From Dictionary    ${DISPLAY_RESOLUTION_DICT}    ${DEFAULT_WINDOW_RESOLUTION}
    ...                             default={"WIDTH": 0, "HEIGHT": 0, "ASPECT": null}
    RETURN    ${display_resolution_values}

Load User Data For New Persistent Context
    [Documentation]    Loads the User Data generated from a page for a New Persistent Context
    ...    example:
    ...    |    Load User Data For New Persistent Context    Navigate To S1 Login Page
    ...
    ...    Arguments:
    ...    - page_load_keyword(str): required
    [Arguments]    ${page_load_keyword}
    IF    '${BROWSER_STRATEGY}'=='persistent'
        TRY
            Directory Should Exist          ${USER_DATA_DIRECTORY}
        EXCEPT    AS    ${error}
            Log                             ${error}                            INFO
            Log                             Creating user data folder ...       CONSOLE
            Create Browser With Context
            Wait Until Keyword Succeeds    2x    1s    Run Keyword    ${page_load_keyword}
            Quit Browser
        END
    END
    [Teardown]    Set Delete User Data Global Variable

Set Delete User Data Global Variable
    [Documentation]    Sets the DELETE_USER_DATA variable
    ...    Defaults to ${TRUE}
    ...
    ...    Sets:
    ...    - DELETE_USER_DATA(bool): GLOBAL
    ...
    TRY
        Variable Should Exist       ${DELETE_USER_DATA}
    EXCEPT
        Set Global Variable     ${DELETE_USER_DATA}     ${TRUE}
    END
    Log                         DELETE_USER_DATA Set To: ${DELETE_USER_DATA}    CONSOLE

Quit Browser
    [Documentation]    Closes the current browser instance
    ...
    ...    Returns:
    ...    - (str): browser id
    ...
    Set Local Variable      @{current_list}     CURRENT
    ${browser_ids}          Get Browser Ids     @{current_list}
    Close Browser           @{current_list}
    RETURN    ${browser_ids}

Quit Context
    [Documentation]    Closes the current context
    ...
    ...    Returns:
    ...    - (str): context id
    ...
    Set Local Variable      @{current_list}     CURRENT             CURRENT
    ${context_ids}          Get Context Ids     @{current_list}
    Close Context           @{current_list}
    RETURN    ${context_ids}

Quit Page
    [Documentation]    Closes the current page
    ...
    ...    Returns:
    ...    - (str): page id
    ...
    Set Local Variable      @{current_list}     CURRENT             CURRENT     CURRENT
    ${page_ids}             Get Page Ids        @{current_list}
    Close Page              @{current_list}
    RETURN    ${page_ids}

Remove User Data For New Persistent Context
    [Documentation]    Removed the user data folder created by New Persistent Context keyword
    Set Delete User Data Global Variable
    IF    '${BROWSER_STRATEGY}'=='persistent' and ${DELETE_USER_DATA}
        TRY
            Wait Until Keyword Succeeds    3x    1s    Empty Directory    ${USER_DATA_DIRECTORY}
            Log                             ${USER_DATA_DIRECTORY} emptied.     CONSOLE
        EXCEPT    AS    ${error}
            Log     ${error}    WARN
        END
    ELSE
        Log     Will not empty ${USER_DATA_DIRECTORY}       CONSOLE
    END

Set Browser Window Resolution
    [Documentation]    Sets the current page viewport size.
    ...
    ...    Args:
    ...    - display_resolution (str): defaults to [$DEFAULT_WINDOW_RESOLUTION]
    ...
    [Arguments]    ${display_resolution}=${DEFAULT_WINDOW_RESOLUTION}
    ${resolutions}                  Get Dictionary Keys                                     ${DISPLAY_RESOLUTION_DICT}
    IF    $display_resolution in $resolutions
        ${display_resolution_values}    Get From Dictionary    ${DISPLAY_RESOLUTION_DICT}    ${display_resolution}
        Set Viewport Size               ${display_resolution_values.WIDTH}      ${display_resolution_values.HEIGHT}
    END

Set User Data Directory Variable
    [Documentation]    Sets the global variable for the browser user data
    ...
    ...    Arguments:
    ...    - user_data_directory(str): defaults to [$DEFAULT_USER_DATA_DIRECTORY]
    ...
    ...    Sets:
    ...    - USER_DATA_DIRECTORY(str): GLOBAL
    ...
    [Arguments]    ${user_data_directory}=${DEFAULT_USER_DATA_DIRECTORY}
    ${user_data_dir}    Join Path    ${EXECDIR}    ${user_data_directory}
    Set Global Variable     ${USER_DATA_DIRECTORY}                                      ${user_data_dir}

Switch Page To Browser Report Page
    [Documentation]    This is an example of how to move between pages.
    [Tags]    robot:private
    ${previous}     Switch Page         NEW
    Get Url
    Close Page
    Switch Page     ${previous}
