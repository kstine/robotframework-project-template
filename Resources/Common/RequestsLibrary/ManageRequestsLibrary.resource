*** Settings ***
Documentation       Keyword file to contain Requests Library common keywords
Library             RequestsLibrary
Library             RequestsContextUtility.py    disable_warnings=${TRUE}
Library             set_urllib3.py
Library             GetSessionData.py
