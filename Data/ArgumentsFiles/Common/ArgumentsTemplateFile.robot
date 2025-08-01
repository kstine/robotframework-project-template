# robocop: off
# ***DO NOT EDIT OR DELETE - COPY FIRST ***
# Copy this file for local executions and place copy in Data/ArgumentsFiles/Local
# This is a Robotframework Arguments File
# It is as easy as running this command. Update this file location at the end:
# robot -A Data/ArgumentsFiles/Local/Arguments.robot
# Refer to section 3.1.4    Argument files in the RF Documentation
# =============================================================================
-A Data/ArgumentsFiles/Common/CommonArguments.robot
-A Data/ArgumentsFiles/Common/PythonPathArguments.robot

--reporttitle Report for S1 Platform Automation Project
--logtitle Log for S1 Platform Automation Project

# -v BROWSER_STRATEGY:persistent
# -v BROWSER_IS_HEADLESS:False
-v SOVOS_ENVIRONMENT:QA
-V Data/ArgumentsFiles/CommonTestData.yaml
--dryrun
-L TRACE
Tests