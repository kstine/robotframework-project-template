# robotframework-project-template

Core project structure for new Robot Framework Repos

## Prerequisites

### Windows PowerShell Execution Policy Setup

**Important for Windows Users:** Before installing any dependencies, you must configure PowerShell's execution policy to allow script execution. This is required for Node.js, npm, and Poetry to function properly.

1. **Open PowerShell as Administrator:**
   - Press `Windows + X` and select "Windows PowerShell (Admin)" or "Terminal (Admin)"
   - Or search for "PowerShell" in the Start menu, right-click, and select "Run as administrator"

2. **Set the execution policy:**

   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

3. **Verify the change:**

   ```powershell
   Get-ExecutionPolicy -Scope CurrentUser
   ```

**Note:** We recommend using `RemoteSigned` instead of `Unrestricted` for better security. This allows local scripts to run while requiring downloaded scripts to be signed by a trusted publisher.

**Alternative (if RemoteSigned doesn't work):**

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

---

**Before setting up this project, ensure you have the following core dependencies installed:**

### 1. Python

- Python [Python Version 3.12](https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe)
  Windows installer (64-bit)

### 2. Poetry (Dependency Management)

- Use the [Official Installer](https://python-poetry.org/docs/#installing-with-the-official-installer)
  Minimum version 2.0+

**Not Required, but useful plugins for Poetry:**

- Install [Poetry Dotenv Plugin](https://github.com/mpeteuil/poetry-dotenv-plugin)

  ```shell
  poetry self add poetry-dotenv-plugin
  ```

- Install [Poetry Plugin: Export](https://github.com/python-poetry/poetry-plugin-export)

  ```shell
  poetry self add poetry-plugin-export
  ```

- Install [Poetry Plugin: Shell](https://github.com/python-poetry/poetry-plugin-shell)

  ```shell
  poetry self add poetry-plugin-shell
  ```

- Install [Poe the Poet Poetry Plugin](https://poethepoet.natn.io/poetry_plugin.html)

  ```shell
  poetry self add 'poethepoet[poetry_plugin]'
  ```

### 3. Node.js (Optional - for web testing)

- Download from [NodeJS](https://nodejs.org/en/download)
  Minimum Version 20+

### 4. Verify installation

```shell
python -V
poetry -V
node -v
npm -v
```

**Or use the verification scripts:**

```powershell
# PowerShell (recommended)
.\Scripts\verify_python_installation.ps1

# Batch file (alternative)
.\Scripts\verify_python_installation.bat
```

```shell
python Scripts/verify_poetry_installation.py
```

```shell
python Scripts/verify_node_installation.py
```

---

## Install Python Dependencies

This project uses Poetry for dependency management. Install all Python dependencies:

> Review the parts about dependency installation and using virtual environments.

- [Poetry Basic Usage](https://python-poetry.org/docs/basic-usage/)

1. From the project root folder:

    ```shell
    poetry install
    ```

2. Wait for the dependencies to be installed, then:

    ```shell
    poetry activate
    ```

3. Start a python virtual environment shell.

    ```shell
    poetry shell
    ```

## Install Additional Dependencies

### Setup Robot Framework Browser drivers and npm dependencies

```shell
rfbrowser init
```

### Install VSCode Extensions

Required:

1. `RobotCode`
2. `Python`
3. `Python Debugger`
4. `Pylint`
5. `isort`
6. `Flake8`

Optional:

1. `Even Better TOML` (linting for the toml config files)
2. `open in browser` (Helps for opening the robot framework test results)
3. `Code Spell Checker` (Assists in spelling in code.)

## Project Structure

- `AzurePipelines/` - Pipeline code files
- `CustomLibraries/` - Custom Python libraries
- `Data/` - Test data and configuration files
- `Resources/` - Reusable keywords and resources
- `Results/` - Test execution results and reports
- `Scripts/` - Useful project scripts
- `Tasks/` - Task-specific configurations
- `Tests/` - Robot Framework test files

[Directory Tree](directorytree.md)

## Running Tests

It is best to configure your IDE ahead of time.
[Set Python Interpreter Path](https://code.visualstudio.com/docs/python/environments#_using-the-create-environment-command)

### Running Tests Within A Python Virtual Environment

1. Open a terminal session (VSCode preferred).
2. From the root folder of the project:

    ```shell
    poetry shell
    ```

### Running using Robot Framework

While robot arguments can be passed in the commandline:

```shell
robot -d Results -x junit.xml --pythonpath . --pythonpath CustomLibraries --pythonpath Resources --reporttitle "Report of Project" --logtitle "Log of Project" -s BrowserTest Tests
```

It is best practice to leverage arguments files:

```shell
robot -A Data/ArgumentsFiles/Common/RunAllExamples.robot Tests
```

### Running using RobotCode

Alternately you can leverage RobotCode extension.
[RobotCode](https://robotcode.io/01_about/#running-and-debugging)

An equivalent to the robot framework example:

```shell
robotcode -p local robot
```

The profiles are managed in the `robot.toml` file.

You can make an overriding local file by copying the `robot.toml` and renaming it `.robot.toml`.

## Project Configuration Files

- `pyproject.toml` - Poetry configuration and dependencies
- `robocop.toml` - Robocop linting configuration
- `robot.toml` - RobotCode configuration
