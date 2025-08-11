*** Comments ***
Resource for dealing with common selenium library keywords.
This is a common resource for all the selenium library keywords.
It is used to configure the selenium library and create a browser instance.
It is also used to clean the download folder and set the window resolution.
Webdriver Strategy:
    - remote: uses a remote webdriver server
    - docker-compose: leverages the docker network created by docker compose (multiple containers)
    - local: uses a local webdriver to run the browser (default setting)


*** Settings ***
Documentation       Keyword file to contain Selenium Library common keywords
Library             Collections
Library             OperatingSystem
Library             SeleniumLibrary    plugins=${CURDIR}${/}WaitForStablePlugin.py
Variables           SeleniumLibraryConfiguration.yaml


*** Variables ***
&{WEB_BROWSER_ARGUMENTS}        browser=${WEB_BROWSER}
${WEB_BROWSER_DOWNLOAD_PATH}    ${EMPTY}
@{CHROME_OPTIONS_LIST}
...                             add_argument('--ignore-certificate-errors')
# Other useful options:
# ...    add_argument('--allow-running-insecure-content')
# ...    add_argument('--disable-web-security')
# ...    add_argument('--enable-javascript')
# ...    add_argument('--enable-scripts')
# ...    add_argument('--guest')
# ...    add_argument('--ignore-ssl-errors')


*** Keywords ***
Clean Local Download Folder
    [Documentation]    Clears all files from the Download Folder.
    ...
    ...    Requires:
    ...    - WEB_BROWSER_DOWNLOAD_PATH (str): download_path
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
    ...    - WEB_BROWSER_DOWNLOAD_PATH (str): download_path
    ...
    TRY
        Variable Should Exist       ${WEB_BROWSER_DOWNLOAD_PATH}
    EXCEPT
        ${path}                 Join Path                       ${EXECDIR}      Downloads
        Set Suite Variable      ${WEB_BROWSER_DOWNLOAD_PATH}    ${path}  # robocop: off=replace-set-variable-with-var
    END
    Log                         Download Folder: ${WEB_BROWSER_DOWNLOAD_PATH}       INFO

Configure WebDriver Options
    [Documentation]    Sets chrome webdriver options.
    ...
    ...    Arguments:
    ...    - browser (str): defaults to [chrome]
    ...    - strategy (str): defaults to [local]
    ...    - download_path (str): defaults to [Downloads]
    ...    - options_list (list): defaults to [CHROME_OPTIONS_LIST]
    ...    - is_headless (bool): defaults to [BROWSER_IS_HEADLESS]
    ...
    ...    Sets:
    ...    - WEB_BROWSER_ARGUMENTS (dict): options
    ...
    ...    Requires:
    ...    - WEB_BROWSER_ARGUMENTS (dict): browser
    ...    - SELENIUM_STRATEGY (str): strategy
    ...    - WEB_BROWSER_DOWNLOAD_PATH (str): download_path
    ...    - CHROME_OPTIONS_LIST (list): options_list
    ...    - BROWSER_IS_HEADLESS (bool): is_headless
    ...
    [Tags]    robot:private
    [Arguments]    ${browser}=${WEB_BROWSER}
    ...    ${strategy}=${SELENIUM_STRATEGY}
    ...    ${download_path}=${WEB_BROWSER_DOWNLOAD_PATH}
    ...    ${options_list}=${CHROME_OPTIONS_LIST}
    ...    ${is_headless}=${BROWSER_IS_HEADLESS}
    IF    '${browser}'=='chrome'
        ${options_list}    Set Local Chrome Preferences    ${options_list}    ${strategy}    ${download_path}
        ${options_list}    Set Remote Chrome Preferences    ${options_list}    ${strategy}    ${download_path}
        ${options_string}       Create Selenium Options String      ${options_list}
        ${options_string}       Set Chrome Headless Options         ${is_headless}                  ${options_string}
        Set To Dictionary       ${WEB_BROWSER_ARGUMENTS}            options=${options_string}
    END

Create Docker Compose Selenium Browser
    [Documentation]    Creates a browser instance by connecting to a docker image.
    ...    The image should be set up to connect to a host volume for download tests.
    ...
    ...    Requires:
    ...    - WEB_BROWSER_ARGUMENTS
    ...    - DOCKER_COMPOSE_CONFIGURATION
    ...
    Configure WebDriver Options
    Set To Dictionary                           ${WEB_BROWSER_ARGUMENTS}
    ...                                         remote_url=${DOCKER_COMPOSE_CONFIGURATION.URL}
    Open Browser                                &{WEB_BROWSER_ARGUMENTS}
    Set Selenium Browser Window Resolution

Create Local Download Directory
    [Documentation]    Creates Directory if it does not exist.
    Create Directory    ${WEB_BROWSER_DOWNLOAD_PATH}

Create Local Selenium Browser
    [Documentation]    Opens browser based on locally installed webdrivers.
    ...    Not compatible with webdriver servers or other webdriver
    ...    service (browserstack or sauce labs).
    ...
    ...    Requires:
    ...    - WEB_BROWSER_ARGUMENTS
    ...    - CHROME_EXECUTABLE_PATH
    ...
    Configure WebDriver Options
    IF    $CHROME_EXECUTABLE_PATH is not None
        Set To Dictionary       ${WEB_BROWSER_ARGUMENTS}    executable_path=${CHROME_EXECUTABLE_PATH}
    END
    Open Browser                                &{WEB_BROWSER_ARGUMENTS}
    Set Selenium Browser Window Resolution

Create Remote Selenium Browser
    [Documentation]    This creates a browser to be used for remote connection with webdriver-manager
    ...    First creates a suite level variable for the download path if one does not exist.
    ...    Then sets the capabilities of the browser.
    ...
    ...    Requires:
    ...    - WEB_BROWSER_ARGUMENTS
    ...    - REMOTE_WEBDRIVER_CONFIGURATION
    ...
    Configure WebDriver Options
    Set To Dictionary                           ${WEB_BROWSER_ARGUMENTS}
    ...                                         remote_url=${REMOTE_WEBDRIVER_CONFIGURATION.URL}
    Open Browser                                &{WEB_BROWSER_ARGUMENTS}
    Set Selenium Browser Window Resolution

Create Selenium Browser Instance
    [Documentation]    Opens a browser based on SELENIUM_STRATEGY.
    ...    Valid values: remote, docker-compose, local
    ...
    ...    Requires:
    ...    - SELENIUM_STRATEGY
    ...    - SELENIUM_CONFIGURATION.TIMEOUT
    ...
    Log    \nWebdriver Strategy: ${SELENIUM_STRATEGY}    CONSOLE
    Configure Download Path
    Create Local Download Directory
    IF    '${SELENIUM_STRATEGY}'=='remote'
        Create Remote Selenium Browser
    ELSE IF    '${SELENIUM_STRATEGY}'=='docker-compose'
        Create Docker Compose Selenium Browser
    ELSE IF    '${SELENIUM_STRATEGY}'=='local'
        Create Local Selenium Browser
    ELSE
        Fail    msg=Choose one of the valid options: [remote, docker-compose, local]
    END
    Set Selenium Timeout                        ${SELENIUM_CONFIGURATION.TIMEOUT}

Create Selenium Options String
    [Documentation]    Create a selenium options string.
    ...
    ...    Arguments:
    ...    - options_list (list): required
    ...    - options_string (str): defaults to [None]
    ...
    ...    Returns:
    ...    - options_string (str): updated options string
    ...
    [Tags]    robot:private
    [Arguments]    ${options_list}    ${options_string}=${NONE}
    IF    $options_string is None
        ${options_string}       Catenate                SEPARATOR=;     @{options_list}
    ELSE
        ${options_string}       Catenate                SEPARATOR=;
        ...                     ${options_string}
        ...                     @{options_list}
    END
    RETURN    ${options_string}

Get Window Resolution Configuration
    [Documentation]    Get the window resolution configuration.
    ...
    ...    Arguments:
    ...    - display_resolution (str): required
    ...
    ...    Returns:
    ...    - display_resolution_values (dict): {'HEIGHT': str, 'WIDTH': str, 'ASPECT': str}
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

Quit Selenium Browser
    [Documentation]    Closes the current selenium browser instance
    ...    Does not close any web servers.
    ...
    ...    Returns:
    ...    - (str): session id
    ...
    ${session_id}       Get Session Id
    Close Browser
    RETURN    ${session_id}

Set Chrome Headless Options
    [Documentation]    Set the chrome headless options.
    ...
    ...    Arguments:
    ...    - is_headless (bool): required
    ...    - options (str): required
    ...
    ...    Returns:
    ...    - options (str): updated options string
    ...
    [Tags]    robot:private
    [Arguments]    ${is_headless}    ${options}
    IF    ${is_headless}
        ${options}      Catenate                            SEPARATOR=;
        ...             ${options}
        ...             add_argument("--disable-gpu")
        ...             add_argument("--headless")
        ...             add_argument("--no-sandbox")
    END
    RETURN    ${options}

Set Local Chrome Preferences
    [Documentation]    Set the local chrome preferences.
    ...
    ...    Arguments:
    ...    - options (list): required
    ...    - strategy (str): required
    ...    - download_path (str): required
    ...
    ...    Returns:
    ...    - options (list): updated options list
    ...
    [Tags]    robot:private
    [Arguments]    ${options}    ${strategy}    ${download_path}
    IF    '${strategy}' in ['local']
        # robocop: off=replace-create-with-var
        Append To List      ${options}              add_experimental_option('excludeSwitches', ['enable-logging'])
        ${prefs}            Create Dictionary       download.default_directory=${download_path}
        Append To List      ${options}              add_experimental_option('prefs', ${prefs})
    END
    RETURN    ${options}

Set Remote Chrome Preferences
    [Documentation]    Set the remote chrome preferences.
    ...
    ...    Arguments:
    ...    - options (list): required
    ...    - strategy (str): required
    ...    - download_path (str): required
    ...
    ...    Returns:
    ...    - options (list): updated options list
    ...
    [Tags]    robot:private
    [Arguments]    ${options}    ${strategy}    ${download_path}
    IF    '${strategy}' in ['remote']
        # robocop: off=replace-create-with-var
        ${prefs}            Create Dictionary       download.default_directory=${download_path}
        Append To List      ${options}              add_experimental_option('prefs', ${prefs})
    END
    RETURN    ${options}

Set Selenium Browser Window Resolution
    [Documentation]    Sets the window size.
    ...
    ...    Arguments:
    ...    - display_resolution (str): defaults to [$DEFAULT_WINDOW_RESOLUTION]
    ...
    ...    Requires:
    ...    - DEFAULT_WINDOW_RESOLUTION (str): display_resolution
    ...
    [Arguments]    ${display_resolution}=${DEFAULT_WINDOW_RESOLUTION}
    TRY
        Get Window Size     inner=${TRUE}
    EXCEPT    AS    ${error}
        Fail    msg=${error}
    END
    IF    $display_resolution=='MAX'
        Maximize Browser Window
        ${max_size}                     Get Window Size                             inner=${TRUE}
        Log                             Window size set to maximum: ${max_size}     INFO
    ELSE
        ${display_resolution_values}    Get Window Resolution Configuration     ${display_resolution}
        Set Window Size    ${display_resolution_values.WIDTH}    ${display_resolution_values.HEIGHT}    inner=${TRUE}
        Verify Window Resolution        ${display_resolution_values}
    END

Verify Window Resolution
    [Documentation]    Verify the window resolution is set correctly.
    ...
    ...    Arguments:
    ...    - display_resolution_values (dict): {'HEIGHT': str, 'WIDTH': str, 'ASPECT': str}
    ...
    ...    Requires:
    ...    - DISPLAY_RESOLUTION_DICT (dict): display_resolution_dict
    ...
    [Tags]    robot:private
    [Arguments]    ${display_resolution_values}
    ${expected_size}                Create List  # robocop: off=replace-create-with-var
    ...                             ${display_resolution_values.WIDTH}
    ...                             ${display_resolution_values.HEIGHT}
    ${actual_size}                  Get Window Size                         inner=${TRUE}
    FOR    ${actual_size_value}    ${expected_size_value}    IN ZIP    ${actual_size}    ${expected_size}
        Should Be Equal As Numbers      ${actual_size_value}    ${expected_size_value}
    END
