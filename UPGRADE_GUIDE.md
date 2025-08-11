# Robot Framework Project Template - Upgrade Guide

This guide helps you migrate your legacy Robot Framework project to the modern template structure with Python 3.12+, Robot Framework 7.x, Poetry dependency management, and optional Browser Library support.

## Overview

**From:** Legacy Robot Framework project (Python 3.9, RF4, SeleniumLibrary, requirements.txt)
**To:** Modern template (Python 3.12+, RF7, Poetry, Browser Library, structured project layout)

## Version Compatibility Matrix

| **Component** | **Legacy** | **Template** | **Breaking Changes** |
|---------------|------------|--------------|---------------------|
| Python | 3.9 | 3.12+ | Type hints, performance improvements |
| Robot Framework | 4.x | 7.3.2 | Keyword deprecations, syntax updates |
| SeleniumLibrary | 5.x | 6.7.1 | WebDriver 4.0 changes |
| Browser Library | N/A | 19.7.0 | New syntax, Playwright backend |
| Poetry | N/A | 2.0+ | Replaces pip/pipenv |
| Node.js | N/A | 20+ | Required for Browser Library |

## Migration Timeline Estimates

- **Small Project** (< 50 tests): 4-8 hours
- **Medium Project** (50-200 tests): 1-2 days
- **Large Project** (200+ tests): 3-5 days
- **Enterprise Project** (500+ tests): 1-2 weeks

*Timeline includes testing, validation, and team training.*

## Prerequisites

### 1. Environment Setup

#### Windows PowerShell Execution Policy (Windows Users Only)

Before installing dependencies, configure PowerShell execution policy:

```powershell
# Run as Administrator
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
Get-ExecutionPolicy -Scope CurrentUser  # Verify
```

#### Core Dependencies

- **Python 3.12+**: [Download Python 3.12.10](https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe)
- **Poetry 2.0+**: [Official Installer](https://python-poetry.org/docs/#installing-with-the-official-installer)
- **Node.js 20+** (Optional): [Download Node.js](https://nodejs.org/en/download)

#### Poetry Plugins (Recommended)

```bash
poetry self add poetry-dotenv-plugin
poetry self add poetry-plugin-export
poetry self add poetry-plugin-shell
poetry self add 'poethepoet[poetry_plugin]'
```

### 2. Verification Scripts

Use the template's verification scripts to ensure proper setup:

```bash
# PowerShell (Windows)
.\Scripts\verify_python_installation.ps1

# Python verification
python Scripts/verify_python_installation.py
python Scripts/verify_poetry_installation.py
python Scripts/verify_node_installation.py
```

## Migration Steps

### Step 1: Project Structure Migration

Adopt the new directory structure:

```
robot-template/
├── AzurePipelines/          # CI/CD pipeline configurations
├── CustomLibraries/         # Custom Python libraries
├── Data/                    # Test data and configuration files
│   └── ArgumentsFiles/      # Robot Framework argument files
├── Resources/               # Reusable keywords and resources
│   ├── Common/             # Shared resources
│   └── [YourDomain]/       # Domain-specific resources
├── Results/                 # Test execution results
├── Scripts/                 # Project utility scripts
├── Tasks/                   # Task-specific configurations
├── Tests/                   # Robot Framework test files
├── pyproject.toml          # Poetry configuration
├── robot.toml              # RobotCode configuration
└── robocop.toml            # Code quality configuration
```

**Migration Actions:**

- Move your existing test files to `Tests/`
- Move resource files to `Resources/`
- Move custom Python libraries to `CustomLibraries/`
- Create `Data/ArgumentsFiles/` for your argument files

### Step 2: Dependency Management Migration

#### Option A: From requirements.txt to pyproject.toml

**Old approach:**

```bash
pip install -r requirements.txt
```

**New approach:**

```bash
poetry install
```

#### Option B: From pipenv to poetry

**Old pipenv approach:**

```bash
pipenv install
pipenv shell
pipenv run robot Tests/
```

**New poetry approach:**

```bash
poetry install
poetry shell
poetry run robot Tests/
```

**Migration steps from pipenv:**

1. **Export current dependencies:**

   ```bash
   # Export from pipenv to requirements.txt
   pipenv requirements > requirements.txt

   # Or export with dev dependencies
   pipenv requirements --dev > requirements-dev.txt
   ```

2. **Convert to pyproject.toml:**

   ```bash
   # Initialize poetry project (if not using template)
   poetry init

   # Add dependencies from requirements.txt
   poetry add $(cat requirements.txt)

   # Add dev dependencies
   poetry add --group dev $(cat requirements-dev.txt)
   ```

3. **Migrate virtual environment:**

   ```bash
   # Remove old pipenv environment
   pipenv --rm

   # Create new poetry environment
   poetry install
   poetry shell
   ```

4. **Update scripts and CI/CD:**

   ```bash
   # Old pipenv commands
   pipenv run robot Tests/
   pipenv run robocop

   # New poetry commands
   poetry run robot Tests/
   poetry run robocop
   ```

**Key differences:**

- **Lock file**: `Pipfile.lock` → `poetry.lock`
- **Config file**: `Pipfile` → `pyproject.toml`
- **Commands**: `pipenv` → `poetry`
- **Groups**: pipenv uses `[packages]` and `[dev-packages]` → poetry uses dependency groups

The template includes dependency groups for different use cases:

- **browser**: Robot Framework Browser Library
- **common**: Core utilities (lxml, openpyxl, pyyaml, etc.)
- **framework**: Robot Framework core and tools
- **selenium**: SeleniumLibrary (legacy support)
- **requests**: HTTP testing libraries
- **oracledb**: Database testing
- **ssh**: SSH automation
- **reporting**: Test reporting tools (optional)
- **script**: Scripting utilities (optional)

**Install specific groups:**

```bash
# Install core testing dependencies
poetry install --with framework,common

# Install browser automation
poetry install --with browser

# Install both browser libraries for comparison
poetry install --with browser,selenium

# Install everything including optional tools
poetry install --with browser,selenium,reporting,script

# Install only essential dependencies
poetry install --without dev,reporting,script
```

### Step 3: Robot Framework Configuration

#### From command-line arguments to robot.toml profiles

**Old approach:**

```bash
robot -d Results -x junit.xml --pythonpath . --pythonpath CustomLibraries Tests
```

**New approach:**

```bash
robotcode -p run-all robot          # Run all tests
robotcode -p browser robot          # Run browser tests only
robotcode -p dryrun-all robot       # Dry run all tests
```

**Available profiles in robot.toml:**

- `local`: Uses argument files, good for development
- `run-all`: Runs all tests in Tests/ directory
- `browser`: Browser-specific tests
- `requests`: HTTP testing
- `keyword-acceptance`: Keyword acceptance tests
- `dryrun-all`: Dry run mode for validation

### Step 4: Browser Automation Migration

#### Option A: Migrate to Browser Library (Recommended)

**Old SeleniumLibrary approach:**

```robotframework
*** Settings ***
Library    SeleniumLibrary

*** Test Cases ***
Open Website
    Open Browser    https://example.com    chrome
    Click Element    id=login-button
    Input Text    id=username    myuser
    Close Browser
```

**New Browser Library approach:**

```robotframework
*** Settings ***
Library    Browser

*** Test Cases ***
Open Website
    New Browser    browser=chromium    headless=false
    New Context
    New Page    https://example.com
    Click    id=login-button
    Fill Text    id=username    myuser
    Close Browser
```

**Key Browser Library changes:**

| **SeleniumLibrary** | **Browser Library** | **Notes** |
|-------------------|-------------------|-----------|
| `Open Browser` | `New Browser` + `New Context` + `New Page` | Multi-step process |
| `Click Element` | `Click` | Simplified syntax |
| `Input Text` | `Fill Text` | More reliable input |
| `Get Text` | `Get Text` | Similar syntax |
| `Wait Until Element Is Visible` | `Wait For Elements State    visible` | More explicit |
| `Element Should Be Visible` | `Get Element States    should contain    visible` | State-based validation |
| `Get Element Attribute` | `Get Attribute` | Similar syntax |
| `Execute Javascript` | `Evaluate Javascript` | Enhanced capabilities |
| `Select From List By Label` | `Select Options By    label` | More flexible |
| `Switch Window` | `Switch Page` | Context-aware |

**Performance Benefits:**

- ⚡ **50-70% faster** test execution
- 🛡️ **More reliable** element detection with auto-wait
- 🔄 **Reduced flaky tests** through built-in stability
- 📱 **Mobile testing** support included
- 🎯 **Better error messages** for debugging

**Setup Browser Library:**

```bash
poetry install --with browser
rfbrowser init
```

#### Option B: Update SeleniumLibrary Usage

If you prefer to keep SeleniumLibrary, the template includes enhanced SeleniumLibrary resources with better validation and error handling.

**Enhanced features in ManageSeleniumLibrary.resource:**

- Input validation for window resolution
- Browser state verification
- Comprehensive error messages
- Post-operation verification

### Step 5: Code Quality and Linting

The template includes RoboCop for code quality:

```bash
# Run RoboCop linting
robocop

# Run with specific rules
robocop --include 0201,0202

# Generate report
robocop --output Reports/robocop-report.html
```

**Configuration in robocop.toml:**

- Custom rule configurations
- Ignore patterns
- Output formatting

### Step 6: CI/CD Pipeline Migration

#### Azure DevOps Pipeline Updates

**Old approach:**

```yaml
steps:
- script: pip install -r requirements.txt
  displayName: 'Install dependencies'
- script: robot -d Results Tests/
  displayName: 'Run tests'
```

**New approach:**

```yaml
steps:
- script: poetry install --with browser,selenium
  displayName: 'Install dependencies'
- script: poetry run robotcode -p run-all robot
  displayName: 'Run tests'
```

#### GitHub Actions Updates

**Old approach:**

```yaml
- name: Install dependencies
  run: pip install -r requirements.txt
- name: Run tests
  run: robot -d Results Tests/
```

**New approach:**

```yaml
- name: Install Poetry
  uses: snok/install-poetry@v1
- name: Install dependencies
  run: poetry install --with browser,selenium
- name: Run tests
  run: poetry run robotcode -p run-all robot
```

#### Jenkins Pipeline Updates

**Old approach:**

```groovy
stage('Test') {
    steps {
        sh 'pip install -r requirements.txt'
        sh 'robot -d Results Tests/'
    }
}
```

**New approach:**

```groovy
stage('Test') {
    steps {
        sh 'poetry install --with browser,selenium'
        sh 'poetry run robotcode -p run-all robot'
    }
}
```

### Step 7: Test Execution and Reporting

#### Using RobotCode (Recommended)

```bash
# Activate virtual environment
poetry shell

# Run tests with profiles
robotcode -p run-all robot
robotcode -p browser robot
robotcode -p smoke robot

# Debug mode
robotcode --loglevel TRACE -p run-all robot
```

#### Using Robot Framework directly

```bash
# Using argument files
robot -A Data/ArgumentsFiles/Common/RunAllExamples.robot Tests

# Using profiles
robot --config robot.toml --profile run-all Tests
```

## Common Migration Pitfalls

### ❌ **Pitfall 1: Mixed Dependency Managers**

**Problem:** Using both pip and poetry in same project
**Solution:**

```bash
# Remove pip-installed packages
pip freeze > old_requirements.txt
pip uninstall -r old_requirements.txt -y
# Then install with poetry
poetry install
```

### ❌ **Pitfall 2: Python Path Issues**

**Problem:** Import errors after migration
**Solution:** Verify robot.toml pythonpath configuration:

```toml
extend-python-path = [".", "Resources", "CustomLibraries"]
```

### ❌ **Pitfall 3: Browser Library Initialization**

**Problem:** "rfbrowser init" fails
**Solution:**

```bash
# Ensure Node.js 20+ installed
node --version
# Force initialization
rfbrowser init --force
# Skip browser download if needed
rfbrowser init --skip-browsers
```

### ❌ **Pitfall 4: Poetry Command Syntax**

**Problem:** `poetry add $(cat requirements.txt)` fails
**Solution:** Use more reliable approach:

```bash
# Method 1: Line by line
cat requirements.txt | xargs -n 1 poetry add

# Method 2: Convert to space-separated
cat requirements.txt | tr '\n' ' ' | xargs poetry add
```

### ❌ **Pitfall 5: Virtual Environment Conflicts**

**Problem:** Tests work in old environment but fail in new one
**Solution:**

```bash
# Clear all environments
poetry env remove --all
# Recreate clean environment
poetry install
poetry shell
```

## Troubleshooting

### Common Issues and Solutions

#### Poetry/Python Version Issues

```bash
# Verify Python version
python --version  # Should be 3.12+

# Verify Poetry installation
poetry --version  # Should be 2.0+

# Clear Poetry cache if needed
poetry cache clear --all pypi
```

#### Robot Framework Syntax Errors

- Check for deprecated keywords between RF4 and RF7
- Verify spacing and indentation
- Use `robotcode --loglevel TRACE` for detailed error messages

#### Browser Library Setup Issues

```bash
# Verify Node.js installation
node --version  # Should be 20+

# Reinitialize Browser Library
rfbrowser init --force

# Check Browser Library installation
rfbrowser --version
```

#### Import Errors

- Check `pythonpath` configuration in `robot.toml`
- Verify library installations: `poetry show`
- Check for missing dependencies in `pyproject.toml`

#### Pipenv Migration Issues

```bash
# If pipenv requirements export fails
pipenv lock --requirements > requirements.txt

# If poetry add fails with version conflicts
poetry add --no-dev  # Add without dev dependencies first
poetry add --group dev  # Then add dev dependencies

# Clear poetry cache if needed
poetry cache clear --all pypi

# Verify poetry environment
poetry env info
poetry show --tree
```

#### Test Failures

- Use `robotcode --loglevel TRACE` for detailed logging
- Check `Results/log.html` for test execution details
- Verify browser/application state before test execution

#### Advanced Troubleshooting

**Robot Framework Version Conflicts:**

```bash
# Check for multiple RF installations
pip list | grep robot
poetry show | grep robot

# Remove pip-installed RF packages
pip uninstall robotframework robotframework-seleniumlibrary -y
```

**Browser Library vs SeleniumLibrary Conflicts:**

```bash
# Install only one browser automation library
poetry install --with browser --without selenium
# OR
poetry install --with selenium --without browser
```

**Performance Issues:**

```bash
# Enable parallel execution
robotcode -p run-all robot --processes 4

# Use headless mode for faster execution
robotcode -p run-all robot -v HEADLESS:true

# Optimize Browser Library settings
rfbrowser init --skip-browsers  # Skip browser downloads
```

**Memory Issues with Large Test Suites:**

```bash
# Run tests in smaller batches
robotcode -p browser robot
robotcode -p requests robot

# Increase memory limits
export ROBOT_OPTIONS="--maxerrorlines 10"
```

### Debugging Tips

1. **Use RobotCode debugging:**

   ```bash
   robotcode --loglevel TRACE -p run-all robot
   ```

2. **Check test results:**
   - Open `Results/log.html` in browser
   - Review `Results/report.html` for summary
   - Check `Results/output.xml` for detailed data

3. **Validate configuration:**

   ```bash
   # Test configuration without running tests
   robotcode -p dryrun-all robot
   ```

## Migration Success Validation

### ✅ **Validation Checklist**

- [ ] All tests execute without import errors
- [ ] Test execution time improved (with Browser Library)
- [ ] Poetry virtual environment working correctly
- [ ] CI/CD pipeline passing
- [ ] Team can run tests locally
- [ ] No dependency conflicts
- [ ] Test reports generate properly

### 🧪 **Validation Commands**

**Environment Validation:**

```bash
# Verify Python version
python --version  # Should be 3.12+

# Verify Poetry environment
poetry env info
poetry show --tree

# Check for dependency conflicts
poetry check
```

**Test Validation:**

```bash
# Validate configuration without running tests
robotcode -p dryrun-all robot

# Run single test to verify setup
robotcode -p run-all robot --maxfail 1

# Run smoke tests for quick validation
robotcode -p browser robot --include smoke
```

**Performance Validation:**

```bash
# Time test execution (before/after comparison)
time poetry run robotcode -p run-all robot

# Check test results
open Results/report.html  # Review execution summary
open Results/log.html     # Check for errors/warnings
```

## Migration Checklist

### **Phase 1: Environment Setup**

- [ ] Install Python 3.12+
- [ ] Install Poetry 2.0+
- [ ] Install Node.js 20+ (if using Browser Library)
- [ ] Install Poetry plugins (dotenv, export, shell, poethepoet)
- [ ] Run verification scripts
- [ ] Configure PowerShell execution policy (Windows)

### **Phase 2: Project Structure**

- [ ] Create new directory structure
- [ ] Move test files to Tests/
- [ ] Move resource files to Resources/
- [ ] Move custom libraries to CustomLibraries/
- [ ] Create Data/ArgumentsFiles/ directory

### **Phase 3: Dependency Management Migration**

- [ ] **From requirements.txt:**
  - [ ] Backup existing requirements.txt
  - [ ] Create pyproject.toml with template structure
  - [ ] Convert dependencies to Poetry format
- [ ] **From pipenv:**
  - [ ] Export pipenv dependencies to requirements.txt
  - [ ] Remove pipenv environment
  - [ ] Convert to Poetry format
- [ ] Install dependencies with Poetry
- [ ] Verify dependency installation
- [ ] Update CI/CD scripts to use Poetry commands

### **Phase 4: Code Migration**

- [ ] Update Robot Framework syntax (RF4 → RF7)
- [ ] **Browser automation migration:**
  - [ ] Choose Browser Library or updated SeleniumLibrary
  - [ ] Update test keywords and syntax
  - [ ] Initialize Browser Library (if chosen)
- [ ] Configure robot.toml profiles
- [ ] Update import statements and paths

### **Phase 5: Quality & Testing**

- [ ] Set up RoboCop linting
- [ ] Run dry-run tests for validation
- [ ] Execute smoke tests
- [ ] Run full test suite
- [ ] Verify test reports generation

### **Phase 6: CI/CD & Documentation**

- [ ] Update CI/CD pipelines (Azure DevOps/GitHub Actions/Jenkins)
- [ ] Update team documentation
- [ ] Train team on new processes
- [ ] Create migration notes for future reference

### **Phase 7: Validation & Cleanup**

- [ ] Run migration success validation
- [ ] Performance comparison (before/after)
- [ ] Remove old dependency files
- [ ] Archive legacy setup documentation

## Resources

### Documentation

- [Robot Framework 7.x Documentation](https://robotframework.org/robotframework/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [Browser Library Guide](https://marketsquare.github.io/robotframework-browser/)
- [RobotCode Extension](https://robotcode.io/)

### Template Files

**Configuration Files:**

- `pyproject.toml` - Poetry dependency management with organized groups
- `robot.toml` - RobotCode profiles and execution settings
- `robocop.toml` - Code quality rules and linting configuration

**Browser Automation Resources:**

- `Resources/Common/Browser/ManageBrowser.resource` - Modern Browser Library implementation
- `Resources/Common/Browser/BrowserConfiguration.yaml` - Display resolutions and browser settings
- `Resources/Common/SUTSeleniumLibrary/ManageSeleniumLibrary.resource` - Enhanced SeleniumLibrary with validation

**Verification Scripts:**

- `Scripts/verify_python_installation.ps1` - Python setup validation
- `Scripts/verify_poetry_installation.py` - Poetry environment check
- `Scripts/verify_node_installation.py` - Node.js validation for Browser Library

**Example Test Files:**

- `Tests/BrowserTest.robot` - Browser Library test examples
- `Tests/SeleniumTest.robot` - SeleniumLibrary test examples
- `Tests/RequestsTest.robot` - HTTP testing examples

### Support

- Check the [README.md](README.md) for detailed setup instructions
- Review the [directory tree](directorytree.md) for project structure
- Use the verification scripts in the `Scripts/` directory

## Next Steps

After successful migration:

1. **Optimize your tests** using the new template features
2. **Set up CI/CD pipelines** using the AzurePipelines/ templates
3. **Configure reporting** with the optional reporting dependencies
4. **Add custom libraries** to the CustomLibraries/ directory
5. **Create domain-specific resources** in Resources/[YourDomain]/

The modern template provides a solid foundation for scalable, maintainable Robot Framework automation projects.
