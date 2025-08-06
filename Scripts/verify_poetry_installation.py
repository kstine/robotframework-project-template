#!/usr/bin/env python3
"""
Poetry Installation Verification Script

This script verifies that Poetry is installed and checks for required plugins.
"""

import logging
import re
import subprocess
import sys
from typing import List, Tuple

MINIMUM_POETRY_VERSION = "2.0.1"
REQUIRED_PLUGINS = [
    "poetry-plugin-export",
    "poetry-plugin-shell",
    "poetry-dotenv-plugin"
]


class PoetryVerifier:
    def __init__(self):
        self.min_poetry_version = MINIMUM_POETRY_VERSION
        self.required_plugins = REQUIRED_PLUGINS
        self.missing_plugins = []

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
                check=False
            )
            return result.returncode, result.stdout, result.stderr
        except FileNotFoundError:
            return 1, "", f"Command not found: {' '.join(command)}"

    def check_poetry_installed(self) -> bool:
        """
        Check if Poetry is installed and accessible.

        Returns:
            bool: True if Poetry is installed and accessible, False otherwise.
        """
        self.logger.info(
            "Checking Poetry installation and required plugins...")
        self.logger.info("")

        exit_code, stdout, stderr = self.run_command(["poetry", "--version"])
        if exit_code != 0:
            self.logger.error("Poetry is not installed.")
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
        # Remove parentheses and extract version
        clean_version = re.sub(r'[()]', '', version_string.strip())
        parts = clean_version.split('.')

        major = int(parts[0]) if len(parts) > 0 else 0
        minor = int(parts[1]) if len(parts) > 1 else 0
        patch = int(parts[2]) if len(parts) > 2 else 0

        return major, minor, patch

    def check_poetry_version(self) -> bool:
        """Check if Poetry version meets minimum requirements."""
        exit_code, stdout, stderr = self.run_command(["poetry", "--version"])
        if exit_code != 0:
            self.logger.error("Could not get Poetry version.")
            return False

        # Debug: Log the actual output to see the format
        self.logger.debug(f"Poetry version output: '{stdout.strip()}'")

        # Try multiple patterns to match different Poetry version formats
        version_patterns = [
            r'Poetry\s+\(([\d.]+)\)',  # Poetry (2.0.1)
            r'Poetry\s+([\d.]+)',      # Poetry 2.0.1
            r'([\d.]+)',               # Just the version number
        ]

        current_version = None
        for pattern in version_patterns:
            version_match = re.search(pattern, stdout)
            if version_match:
                current_version = version_match.group(1)
                break

        if not current_version:
            self.logger.error("Could not parse Poetry version.")
            self.logger.debug(f"Raw output: '{stdout}'")
            return False

        current_major, current_minor, current_patch = self._parse_version(
            current_version)
        min_major, min_minor, min_patch = self._parse_version(
            self.min_poetry_version)

        self.logger.info(f"Found Poetry version: {current_version}")
        self.logger.info(
            f"Minimum required version: {self.min_poetry_version}")

        # Compare versions
        version_ok = (
            current_major > min_major or
            (current_major == min_major and current_minor > min_minor) or
            (current_major == min_major and current_minor == min_minor
             and current_patch >= min_patch)
        )

        if version_ok:
            self.logger.info(
                f"Poetry version {current_version} meets minimum requirement.")
            return True
        else:
            self.logger.error(
                f"Poetry {self.min_poetry_version} or higher is required. "
                f"Found {current_version}."
            )
            self.logger.info(
                f"Please install Poetry {self.min_poetry_version} or higher.")
            return False

    def check_plugin(self, plugin_name: str) -> bool:
        """Check if a specific plugin is installed."""
        self.logger.info(f"Checking for plugin: {plugin_name}")

        # Try to get plugin list from Poetry
        exit_code, stdout, stderr = self.run_command(
            ["poetry", "self", "show", "plugins"])

        if exit_code == 0 and plugin_name in stdout:
            self.logger.info(f"Plugin {plugin_name} is installed")
            return True
        else:
            self.logger.warning(f"Plugin {plugin_name} is not installed")
            return False

    def check_all_plugins(self) -> int:
        """Check all required plugins and return count of missing ones."""
        self.logger.info("=" * 40)
        self.logger.info("CHECKING REQUIRED POETRY PLUGINS")
        self.logger.info("=" * 40)

        missing_count = 0
        for plugin in self.required_plugins:
            if not self.check_plugin(plugin):
                missing_count += 1
                self.missing_plugins.append(plugin)

        return missing_count

    def print_summary(self, missing_count: int) -> None:
        """Print verification summary."""
        self.logger.info("")
        self.logger.info("=" * 40)
        self.logger.info("PLUGIN VERIFICATION SUMMARY")
        self.logger.info("=" * 40)

        if missing_count == 0:
            self.logger.info("All required Poetry plugins are installed.")
            self.logger.info("")
            self.logger.info(
                "Poetry installation and all required plugins are verified.")
        else:
            self.logger.warning(
                f"{missing_count} required plugin(s) are missing.")
            self.logger.info("")
            self.logger.info("To install missing plugins, run:")
            self.logger.info("poetry self add plugin-name")
            self.logger.info("")
            self.logger.info("Example:")
            for plugin in self.required_plugins:
                self.logger.info(f"poetry self add {plugin}")

    def verify(self) -> int:
        """Main verification method."""
        # Check if Poetry is installed
        if not self.check_poetry_installed():
            return 1

        # Check Poetry version
        if not self.check_poetry_version():
            return 1

        # Check all plugins
        missing_count = self.check_all_plugins()

        # Print summary
        self.print_summary(missing_count)

        # Return appropriate exit code
        return 0 if missing_count == 0 else 1


def main():
    """Main entry point."""
    verifier = PoetryVerifier()
    exit_code = verifier.verify()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
