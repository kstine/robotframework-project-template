# robocop: off
# This is a Robotframework Arguments File
#
# robot -A Data/ArgumentsFiles/Common/DryRunProject.robot
#
# ================================================
--reporttitle "Report for Dry Run of Project"
--logtitle "Log for Dry Run of Project"
-A Data/ArgumentsFiles/Common/CommonArguments.robot
-A Data/ArgumentsFiles/Common/PythonPathArguments.robot
--dryrun
Tests
