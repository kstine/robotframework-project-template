#!/usr/bin/env python3
"""
Node.js Installation Verification Script

This script verifies that Node.js and npm are installed
and meet minimum version requirements.
"""

import logging
import re
import subprocess
import sys
from typing import List, Tuple

MINIMUM_NODE_MAJOR = 20
MINIMUM_NPM_MAJOR = 10


class NodeVerifier:
    def __init__(self):
        self.min_node_major = MINIMUM_NODE_MAJOR
        self.min_npm_major = MINIMUM_NPM_MAJOR

        # Setup logging
        self.setup_logging()

    def setup_logging(self):
        """Setup logging configuration for console output."""
        logging.basicConfig(
            level=logging.INFO,
            format='%(message)s',
            handlers=[
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)

    def run_command(self,
                    command: List[str],
                    capture_output: bool = True
                    ) -> Tuple[int, str, str]:
        """
        Run a command and return exit code, stdout, and stderr.

        Args:
            command (List[str]): The command to run.
            capture_output (bool, optional): Whether to capture output.
                                             Defaults to True.

        Returns:
            Tuple[int, str, str]: The exit code, stdout, and stderr.
        """
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=False,
                shell=True  # Add shell=True for Windows compatibility
            )
            return result.returncode, result.stdout, result.stderr
        except FileNotFoundError:
            return 1, "", f"Command not found: {' '.join(command)}"

    def check_node_installed(self) -> bool:
        """
        Check if Node.js is installed and accessible.

        Returns:
            bool: True if Node.js is installed and accessible, False otherwise.
        """
        exit_code, stdout, stderr = self.run_command(["node", "--version"])
        if exit_code != 0:
            self.logger.error("NodeJS is not installed.")
            return False
        return True

    def check_npm_installed(self) -> bool:
        """
        Check if npm is installed and accessible.

        Returns:
            bool: True if npm is installed and accessible, False otherwise.
        """
        exit_code, stdout, stderr = self.run_command(["npm", "--version"])
        if exit_code != 0:
            self.logger.error(f"npm is not installed. Exit code: {exit_code}")
            if stderr:
                self.logger.error(f"Error: {stderr}")
            return False
        return True

    def _parse_version(self, version_string: str) -> Tuple[int, int, int]:
        """
        Parse version string into major, minor, patch components.

        Args:
            version_string (str): The version string to parse.

        Returns:
            Tuple[int, int, int]: The major, minor, and patch components.
        """
        # Remove 'v' prefix and extract version
        clean_version = re.sub(r'^v', '', version_string.strip())
        parts = clean_version.split('.')

        major = int(parts[0]) if len(parts) > 0 else 0
        minor = int(parts[1]) if len(parts) > 1 else 0
        patch = int(parts[2]) if len(parts) > 2 else 0

        return major, minor, patch

    def check_node_version(self) -> bool:
        """
        Check if Node.js version meets minimum requirements.

        Returns:
            bool: True if Node.js version meets requirements, False otherwise.
        """
        exit_code, stdout, stderr = self.run_command(["node", "--version"])
        if exit_code != 0:
            self.logger.error("Could not get Node.js version.")
            return False

        # Parse version
        current_version = stdout.strip()
        current_major, current_minor, current_patch = self._parse_version(
            current_version)

        self.logger.info(f"Found Node.js version: {current_version}")

        # Compare versions
        if current_major >= self.min_node_major:
            self.logger.info(
                f"Node.js version {current_version} meets minimum requirement."
            )
            return True
        else:
            self.logger.error(
                f"Node.js {self.min_node_major}.x or higher is required. "
                f"Found {current_version}."
            )
            self.logger.info(f"Please install Node.js {self.min_node_major}+.")
            return False

    def check_npm_version(self) -> bool:
        """
        Check if npm version meets minimum requirements.

        Returns:
            bool: True if npm version meets requirements, False otherwise.
        """
        exit_code, stdout, stderr = self.run_command(["npm", "--version"])
        if exit_code != 0:
            self.logger.error("Could not get npm version.")
            return False

        # Parse version
        current_version = stdout.strip()
        current_major, current_minor, current_patch = self._parse_version(
            current_version)

        self.logger.info(f"Found npm version: {current_version}")

        # Compare versions
        if current_major >= self.min_npm_major:
            self.logger.info(
                f"npm version {current_version} meets minimum requirement.")
            return True
        else:
            self.logger.error(
                f"npm {self.min_npm_major}.x or higher is required. "
                f"Found {current_version}."
            )
            self.logger.info(f"Please install npm {self.min_npm_major}+.")
            return False

    def verify(self) -> int:
        """
        Main verification method.

        Returns:
            int: Exit code (0 for success, 1 for failure).
        """
        self.logger.info("Checking Node.js and npm installations...")
        self.logger.info("")

        # Check if Node.js is installed
        if not self.check_node_installed():
            return 1

        # Check Node.js version
        if not self.check_node_version():
            return 1

        # Check if npm is installed
        if not self.check_npm_installed():
            return 1

        # Check npm version
        if not self.check_npm_version():
            return 1

        self.logger.info("")
        self.logger.info("All Node.js and npm prerequisites are satisfied.")
        return 0


def main():
    """Main entry point."""
    verifier = NodeVerifier()
    exit_code = verifier.verify()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
