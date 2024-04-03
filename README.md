# techtest-freepik

## Fixes list

### App execution

1. Add composer version in the `composer.json` to avoid the version fallback
2. Add `composer update` command to sync the `composer.lock` versions, with `--ignore-platform-req=ext-pdo_mysql`

### Source
