*** Comments ***
Resource for dealing with common browser library keywords.
This is a common resource for all the browser library keywords.
It is used to configure the browser library and create a browser instance.
It is also used to clean the download folder and set the window resolution.
Browser Strategy:
    - incognito: creates a new browser and context using a clean incognito browser
    - persistent: creates a new browser and context for production environments
    - debug: creates a new browser and context for demo purposes only


*** Settings ***
Documentation       Keyword file to contain Browser Library common keywords
Library             Collections
Library             OperatingSystem
Library             Browser    plugins=${CURDIR}${/}BrowserUtilitiesPlugin.py
Variables           BrowserConfiguration.yaml


*** Variables ***
${DELETE_USER_DATA}             ${NONE}
&{CONTEXT_ARGUMENTS}            viewport=${NONE}
${USER_DATA_DIRECTORY}          ${NONE}
&{WEB_BROWSER_ARGUMENTS}
...                             browser=${WEB_BROWSER}
...                             headless=${BROWSER_IS_HEADLESS}
${WEB_BROWSER_DOWNLOAD_PATH}    ${EMPTY}
@{WEB_BROWSER_PERMISSIONS}      clipboard-read                      clipboard-write


*** Keywords ***
Clean Local Download Folder
    [Documentation]    Clears all files from the Download Folder.
    ...
    ...    Requires:
    ...    - WEB_BROWSER_DOWNLOAD_PATH
    ...
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
    ...    Sets:
    ...    - WEB_BROWSER_DOWNLOAD_PATH (str): SUITE
    ...
    ...    Requires:
    ...    - WEB_BROWSER_DOWNLOAD_PATH
    ...
    TRY
        Variable Should Exist       ${WEB_BROWSER_DOWNLOAD_PATH}
    EXCEPT
        ${path}                 Join Path                       ${EXECDIR}      Downloads
        Set Suite Variable      ${WEB_BROWSER_DOWNLOAD_PATH}    ${path}  # robocop: off=replace-set-variable-with-var
    END
    Log                         Download Folder: ${WEB_BROWSER_DOWNLOAD_PATH}       INFO

Create Browser With Context
    [Documentation]    Opens a browser with context based on BROWSER_STRATEGY.
    ...    Valid values: incognito, persistent, debug
    ...
    ...    Requires:
    ...    - BROWSER_STRATEGY
    ...    - BROWSER_TIMEOUT
    ...
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
    ...
    ...    Requires:
    ...    - CONTEXT_ARGUMENTS
    ...    - WEB_BROWSER_ARGUMENTS
    ...    - WEB_BROWSER_DOWNLOAD_PATH
    ...    - WEB_BROWSER_PERMISSIONS
    ...
    ${display_resolution_values}    Get Display Resolution Values
    Set To Dictionary               ${CONTEXT_ARGUMENTS}
    ...                             viewport=${display_resolution_values}
    ...                             permissions=${WEB_BROWSER_PERMISSIONS}
    Open Browser                    &{WEB_BROWSER_ARGUMENTS}
    New Context                     &{CONTEXT_ARGUMENTS}

Create Incognito Browser And Context
    [Documentation]    Creates a new browser and context using a clean incognito browser.
    ...
    ...    Requires:
    ...    - CONTEXT_ARGUMENTS
    ...    - DEFAULT_WINDOW_RESOLUTION
    ...    - DISPLAY_RESOLUTION_DICT
    ...    - WEB_BROWSER
    ...    - WEB_BROWSER_ARGUMENTS
    ...    - WEB_BROWSER_DOWNLOAD_PATH
    ...    - WEB_BROWSER_PERMISSIONS
    ...
    ${display_resolution_values}    Get Display Resolution Values
    Set Web Browser Arguments       ${WEB_BROWSER}
    Set To Dictionary               ${WEB_BROWSER_ARGUMENTS}
    ...                             downloadsPath=${WEB_BROWSER_DOWNLOAD_PATH}
    Set To Dictionary               ${CONTEXT_ARGUMENTS}
    ...                             acceptDownloads=True
    ...                             viewport=${display_resolution_values}
    ...                             permissions=${WEB_BROWSER_PERMISSIONS}
    New Browser                     &{WEB_BROWSER_ARGUMENTS}
    New Context                     &{CONTEXT_ARGUMENTS}

Create Local Download Directory
    [Documentation]    Creates Directory if it does not exist.
    Create Directory    ${WEB_BROWSER_DOWNLOAD_PATH}

Create Persistent Browser And Context
    [Documentation]    Creates a new browser and context for production environments.
    ${display_resolution_values}        Get Display Resolution Values
    Set User Data Directory Variable
    Set Web Browser Arguments           ${WEB_BROWSER}
    Set To Dictionary                   ${WEB_BROWSER_ARGUMENTS}
    ...                                 userDataDir=${USER_DATA_DIRECTORY}
    ...                                 downloadsPath=${WEB_BROWSER_DOWNLOAD_PATH}
    Set To Dictionary                   ${CONTEXT_ARGUMENTS}
    ...                                 acceptDownloads=True
    ...                                 viewport=${display_resolution_values}
    ...                                 permissions=${WEB_BROWSER_PERMISSIONS}
    New Persistent Context              &{WEB_BROWSER_ARGUMENTS}                        &{CONTEXT_ARGUMENTS}

Get Display Resolution Values
    [Documentation]    Gets the resolution values from the browser configurations.
    ...
    ...    Arguments:
    ...    - display_resolution (str): defaults to [DEFAULT_WINDOW_RESOLUTION]
    ...
    ...    Returns:
    ...    - display_resolution_values (dict): {'HEIGHT': str, 'WIDTH': str, 'ASPECT': str}
    ...
    ...    Requires:
    ...    - DISPLAY_RESOLUTION_DICT
    ...    - DEFAULT_WINDOW_RESOLUTION
    ...
    [Tags]    robot:private
    [Arguments]    ${display_resolution}=${DEFAULT_WINDOW_RESOLUTION}
    ${display_resolution_values}    Get From Dictionary    ${DISPLAY_RESOLUTION_DICT}    ${display_resolution}
    ...                             default={"WIDTH": 0, "HEIGHT": 0, "ASPECT": null}
    RETURN    ${display_resolution_values}

Get Viewport Size Configuration
    [Documentation]    Get the viewport size configuration.
    ...
    ...    Arguments:
    ...    - display_resolution (str): required
    ...
    ...    Requires:
    ...    - DISPLAY_RESOLUTION_DICT
    ...
    [Tags]    robot:private
    [Arguments]    ${display_resolution}
    TRY
        ${display_resolution_values}    Get From Dictionary
        ...                             ${DISPLAY_RESOLUTION_DICT}
        ...                             ${display_resolution}
    EXCEPT    AS    ${error}
        Fail    msg=Invalid display resolution: ${display_resolution}. Error: ${error}
    END
    Should Be True    ${display_resolution_values.WIDTH} > 0 and ${display_resolution_values.HEIGHT} > 0
    ...               msg=Invalid width or height value must be greater than 0: ${display_resolution_values}
    RETURN    ${display_resolution_values}

Load User Data For New Persistent Context
    [Documentation]    Loads the User Data generated from a page for a New Persistent Context
    ...    example:
    ...    |    Load User Data For New Persistent Context    Navigate To S1 Login Page
    ...
    ...    Arguments:
    ...    - page_load_keyword (str, keyword): required
    ...
    ...    Requires:
    ...    - BROWSER_STRATEGY
    ...    - USER_DATA_DIRECTORY
    ...
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

Quit Browser
    [Documentation]    Closes the current browser instance.
    ...
    ...    Returns:
    ...    - (str): browser id
    ...
    ${current_list}     Create List         CURRENT  # robocop: off=replace-create-with-var
    ${browser_ids}      Get Browser Ids     @{current_list}
    Close Browser       @{current_list}
    RETURN    ${browser_ids}

Quit Context
    [Documentation]    Closes the current context.
    ...
    ...    Returns:
    ...    - (str): context id
    ...
    ${current_list}     Create List         CURRENT             CURRENT  # robocop: off=replace-create-with-var
    ${context_ids}      Get Context Ids     @{current_list}
    Close Context       @{current_list}
    RETURN    ${context_ids}

Quit Page
    [Documentation]    Closes the current page
    ...
    ...    Returns:
    ...    - (str): page id
    ...
    # robocop: off=replace-set-variable-with-var
    # robocop: off=replace-create-with-var
    ${current_list}    Create List    CURRENT    CURRENT    CURRENT
    ${page_ids}         Get Page Ids        @{current_list}
    Close Page          @{current_list}
    RETURN    ${page_ids}

Remove User Data For New Persistent Context
    [Documentation]    Removed the user data folder created by New Persistent Context keyword.
    ...
    ...    Requires:
    ...    - BROWSER_STRATEGY
    ...    - DELETE_USER_DATA
    ...    - USER_DATA_DIRECTORY
    ...
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

Set Browser Viewport Size
    [Documentation]    Sets the current browser viewport size.
    ...
    ...    Arguments:
    ...    - display_resolution (str): defaults to [$DEFAULT_WINDOW_RESOLUTION]
    ...
    ...    Requires:
    ...    - DEFAULT_WINDOW_RESOLUTION
    ...    - DISPLAY_RESOLUTION_DICT
    ...
    [Arguments]    ${display_resolution}=${DEFAULT_WINDOW_RESOLUTION}
    ${display_resolution_values}    Get Viewport Size Configuration                         ${display_resolution}
    Remove From Dictionary          ${display_resolution_values}                            ASPECT
    Set Viewport Size               &{display_resolution_values}
    Get Viewport Size    ALL    ==    ${display_resolution_values}

Set Delete User Data Global Variable
    [Documentation]    Sets the DELETE_USER_DATA variable
    ...
    ...    Sets:
    ...    - DELETE_USER_DATA (bool): GLOBAL
    ...
    ...    Requires:
    ...    - DELETE_USER_DATA
    ...
    ...    Sets:
    ...    - DELETE_USER_DATA (bool): GLOBAL
    ...
    IF    ${DELETE_USER_DATA} is None
        Set Global Variable     ${DELETE_USER_DATA}     ${TRUE}  # robocop: off=replace-set-variable-with-var
    END
    Log                     DELETE_USER_DATA Set To: ${DELETE_USER_DATA}    CONSOLE

Set User Data Directory Variable
    [Documentation]    Sets the global variable for the browser user data
    ...
    ...    Arguments:
    ...    - user_data_directory (str): defaults to [$DEFAULT_USER_DATA_DIRECTORY]
    ...
    ...    Requires:
    ...    - DEFAULT_USER_DATA_DIRECTORY
    ...
    ...    Sets:
    ...    - USER_DATA_DIRECTORY (str): GLOBAL
    ...
    [Arguments]    ${user_data_directory}=${DEFAULT_USER_DATA_DIRECTORY}
    ${user_data_dir}    Join Path    ${EXECDIR}    ${user_data_directory}
    # robocop: off=replace-set-variable-with-var
    Set Global Variable     ${USER_DATA_DIRECTORY}                                      ${user_data_dir}

Set Web Browser Arguments
    [Documentation]    Passes in the arguments for chrome command line tool.
    ...
    ...    Arguments:
    ...    - browser (str): defaults to [chrome]
    ...
    ...    Requires:
    ...    - WEB_BROWSER_ARGUMENTS
    ...    - CHROME_ARGS
    ...
    [Tags]    robot:private
    [Arguments]    ${browser}=${WEB_BROWSER}
    IF    '${browser}'=='chrome'
        Set To Dictionary       ${WEB_BROWSER_ARGUMENTS}    args=${CHROME_ARGS}
    END

Switch Page To Browser Report Page
    [Documentation]    This is an example of how to move between pages.
    [Tags]    robot:private
    ${previous}     Switch Page         NEW
    Get Url
    Close Page
    Switch Page     ${previous}
