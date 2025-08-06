*** Comments ***
CommonLibraryTest.robot - CommonLibrary Keyword Acceptance Tests.
This test suite demonstrates creating acceptance tests for keyword libraries.


*** Settings ***
Documentation       CommonLibrary Keyword Acceptance Tests.
Library             CustomLibraries.CommonLibrary.CommonLibrary    file_path=${TEST_DATA_FILE}
Variables           expected_config.json
Test Tags           common_library_acceptance


*** Variables ***
${TEST_DATA_FILE}       Tests/KeywordAcceptanceTests/test_data.json
${TEST_KEY}             test_config
${TEST_ENV_KEY}         ENVIRONMENT
${TEST_ENV_VALUE}       qa


*** Test Cases ***
CommonLibrary > Load Test Data Test
    [Documentation]    Load test data from a JSON file.
    [Tags]    load_test_data
    ${test_data}        Load Test Data
    Should Be True      ${test_data}

CommonLibrary > Clear Test Data Test
    [Documentation]    Clear test data.
    [Tags]    clear_test_data
    Clear Test Data
    ${test_data}        Get Test Data       ${TEST_KEY}
    Should Be Empty     ${test_data}

CommonLibrary > Get Test Data Test
    [Documentation]    Get test data from a JSON file.
    [Tags]    get_test_data
    [Setup]    Load Test Data    ${TEST_DATA_FILE}
    ${test_config}      Get Test Data       ${TEST_KEY}
    Should Be Equal     ${test_config}      ${EXPECTED_TEST_CONFIG}

CommonLibrary > Set And Get Common Environment Variable Test
    [Documentation]    Set and get common environment variable.
    [Tags]    common_environment_variable
    Set Common Environment Variable     ${TEST_ENV_KEY}                     ${TEST_ENV_VALUE}
    ${environment}                      Get Common Environment Variable     ${TEST_ENV_KEY}
    Should Be Equal                     ${environment}                      ${TEST_ENV_VALUE}
