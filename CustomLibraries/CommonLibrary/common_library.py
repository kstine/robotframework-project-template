"""
Example Common Library for Robot Framework Automation
Provides utility functions and common operations.

Most of the python based functions are available in the robot framework library
as Keywords from the Core Libraries.
"""

import json
from typing import Any, Dict

from robot.api import logger
from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.Collections import Collections
from robot.libraries.OperatingSystem import OperatingSystem


@library(scope="GLOBAL", version="1.0.0")
class CommonLibrary:
    """Common utility functions for automation framework."""

    def __init__(self, file_path: str = None):
        self.file_path = file_path
        self.test_data: dict[str, Any] = {}
        self.built_in = BuiltIn()
        self.operating_system = OperatingSystem()
        self.collections = Collections()

    @keyword("Load Test Data")
    def load_test_data(self, file_path: str = None) -> Dict[str, Any]:
        """
        Load test data from a JSON file.

        Args:
            file_path (str): Path to the JSON file containing test data.

        Returns:
            Dict[str, Any]: Dictionary containing the test data.
        """
        file_path = self.file_path if file_path is None else file_path
        data = self.operating_system.get_file(file_path)
        try:
            self.test_data = data if isinstance(
                data, dict) else json.loads(data)
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON in test data file: {file_path}")
            self.test_data = {}
        return self.test_data

    @keyword("Get Test Data")
    def get_test_data(self, key: str, default: Any = None) -> Any:
        """
        Get value from test data.

        Args:
            key (str): Key to get the value from.
            default (Any): Default value to return if the key is not found.
        """
        default = {} if default is None else default
        return self.collections.get_from_dictionary(self.test_data,
                                                    key,
                                                    default
                                                    )

    @keyword("Get CommonEnvironment Variable")
    def get_common_environment_variable(self,
                                        key: str,
                                        default: str = "") -> str:
        """
        Get common environment variable with default value.

        Args:
            key (str): Key to get the value from.
            default (str): Default value to return if the key is not found.
        """
        return self.operating_system.get_environment_variable(key, default)

    @keyword("Set CommonEnvironment Variable")
    def set_common_environment_variable(self, key: str, value: str) -> None:
        """
        Set common environment variable.

        Args:
            key (str): Key to set the value for.
            value (str): Value to set for the key.
        """
        self.operating_system.set_environment_variable(key, value)

    @keyword("Clear Test Data")
    def clear_test_data(self) -> None:
        """
        Clears test data.

        This function resets the test data dictionary to an empty dictionary.
        It is used to clear the test data after a test is completed.
        """
        self.test_data = {}
        logger.info("Test data cleaned up")


if __name__ == "__main__":

    test_data = "Data/TestData/test_data.json"
    common_library = CommonLibrary()
    common_library.load_test_data(test_data)
    print(common_library.get_test_data("environments"), "\n")
    common_library.set_environment_variable("ENVIRONMENT", "qa")
    print(common_library.get_environment_variable("ENVIRONMENT"), "\n")
    common_library.clear_test_data()
    print(common_library.get_test_data("environments"), "\n")
