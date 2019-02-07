#!/bin/sh

# ------
# StyleLint Checking using script
#
# If git is reporting that your prettified files are still modified
# after committing, you may need to add a post-commit script
# to update git's index as described in this issue.
#
# @see https://prettier.io/docs/en/precommit.html#option-5-bash-script
#
stylefiles=$(git diff --cached --name-only --diff-filter=ACM "*.scss" "*.css" | tr '\n' ' ')
[ -z "$stylefiles" ] && exit 0

for file in $stylefiles
do
  # we only want to lint the staged changes, not any un-staged changes
  git show ":$file" | ./node_modules/.bin/eslint --stdin --stdin-filename "$file"
  if [ $? -ne 0 ]; then
    echo "StyleLint failed on staged file '$file'. Please check your code and try again. You can run StyleLint manually via npm run stylelint."
    # exit with failure status
    exit 1
  fi
done

# Prettify all staged .style files
echo "$stylefiles" | xargs ./node_modules/.bin/prettier-eslint --eslint-config-path ./.stylelintrc.json --list-different --write

# Add back the modified/prettified files to staging
echo "$stylefiles" | xargs git add

exit 0
