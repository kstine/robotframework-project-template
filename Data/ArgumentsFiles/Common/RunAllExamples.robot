# robocop: off
# This is a Robotframework Arguments File
#
# robot -A Data/ArgumentsFiles/Common/RunAllExamples.robot
#
# ================================================
--reporttitle "Report of Project"
--logtitle "Log of Project"
-A Data/ArgumentsFiles/Common/CommonArguments.robot
-A Data/ArgumentsFiles/Common/PythonPathArguments.robot
-s BrowserTest
-s RequestsTest
