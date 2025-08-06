# robotframework-project-template

A Robot Framework template for new projects and update existing projects.



## Prerequisites

Before setting up this project, ensure you have the following core dependencies installed:

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

### 4. Verify installation:

```shell
python -V
poetry -V
node -v
npm -v
```

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

- `Tests/` - Robot Framework test files
- `Resources/` - Reusable keywords and resources
- `Data/` - Test data and configuration files
- `Results/` - Test execution results and reports
- `CustomLibraries/` - Custom Python libraries
- `Tasks/` - Task-specific configurations

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
robot -A Data/ArgumentsFiles/Common/RunAllExamples.robot
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
