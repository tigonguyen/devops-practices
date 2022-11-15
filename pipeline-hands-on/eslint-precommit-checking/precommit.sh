#!/usr/local/bin/zsh

# List new staged Javascript files
echo "--- Listing new staged Javascript files ---"
DEFAULT_IFS="$IFS" # Store the existing IFS
IFS=$'\n'
STAGED_FILES_LIST=($(git diff --cached --name-only | grep -E '\.(js|jsx)$'))
IFS="$DEFAULT_IFS"

echo $STAGED_FILES_LIST

# Check npm or yarn for installing necessary packages
FILE_PATH=${STAGED_FILES_LIST[1]%/*}
FILE="$FILE_PATH/package-lock.json"
echo "--- Installing necessary packages ---"
if [[ -f "$FILE" ]]; then
  IS_NPM=$true
  npm install --save-dev eslint eslint-config-prettier eslint-plugin-prettier
  npm install --save-dev --save-exact prettier
else
  IS_NPM=$false
  yarn add --dev eslint eslint-config-prettier eslint-plugin-prettier
  yarn add --dev --exact prettier
fi

for STAGED_FILE in $STAGED_FILES_LIST
do
  # Creating Eslint and Prettier configuration files
  STAGED_FILE_PATH=${STAGED_FILE%/*}
  ESLINT_FILE="$STAGED_FILE_PATH/.eslintrc.js"
  PRETTIER_FILE="$STAGED_FILE_PATH/.prettierrc.js"
  if [[ ! -f "$ESLINT_FILE" ]]; then
    touch $ESLINT_FILE
    echo "module.exports = {
      root: true,
      env: {
        commonjs: true,
        es2021: true,
        node: true,
      },
      extends: ['eslint:recommended', 'plugin:prettier/recommended'],
      parserOptions: {
        ecmaVersion: 'latest',
      },
      rules: {
        'no-unused-vars': 'warn',
        'no-constant-condition': 'off',
      },
    };" > $ESLINT_FILE
  fi
  if [[ ! -f "$PRETTIER_FILE" ]]; then
   touch $PRETTIER_FILE
    echo "module.exports = {
      semi: true, // semicolons
      trailingComma: 'es5',
      singleQuote: true,
      useTabs: false,
      tabWidth: 2, // spaces not tabs
      bracketSpacing: true,
      arrowParens: 'always',
    };" > $PRETTIER_FILE
  fi
  
  # Linting the current file
  echo "--- Linting $STAGED_FILE ---"
  if [ $IS_NPM = $true ]; then
    npx eslint $STAGED_FILE
    if [ $? -ne 0 ]; then
      echo "ESLint failed on staged file '$STAGED_FILE'. You can use 'npx eslint --fix' option for fixing Prettier problem manually, then stage and commit again"
      exit 1 # exit with failure status
    fi
  else
    yarn run eslint $STAGED_FILE
    if [ $? -ne 0 ]; then
      echo "ESLint failed on staged file '$STAGED_FILE'. You can use 'yarn run eslint --fix' option for fixing Prettier problem manually, then stage and commit again"
      exit 1 # exit with failure status
    fi
  fi
done