# Project Description
This project is built for deploying precommit checking automatically everytime developer hit the `git commit`. This use Eslint as the checking tool, which is useful for static analysis for Javascript project.

## Goals when using Eslint
- Adhere to code style convention
- Identify resource leak
- Identity security vulnerabilities
## Scipt details
- Get staged files list
- Check and install Eslint
- Linting every file with recommend rules (You can change the eslint configuration upto you scenario)
## Usage
- Staged your new changes
- Hit the `git commit`
- Fix the error manually or using `--fix` option
- Stage and hit `git commit` again.