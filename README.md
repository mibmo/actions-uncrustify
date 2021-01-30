# Uncrustify C# Github Action
**Note:** fork of [coleaeason/actions-uncrustify](https://github.com/coleaeason/actions-uncrustify), changes it to format C# instead.

Runs an [uncrustify](https://github.com/uncrustify/uncrustify) config against C# implementation and header files in a given repo. 

The script looks for the following file endings:
* .cs

Only runs on files that have been added or modified in a given commit.

## Example configurations

Basic: 
```yml
on: [ pull_request ]

jobs:
  cpp_style_check:
    runs-on: ubuntu-latest
    name: Check C# Style
    steps:
    - name: Checkout this commit
      uses: actions/checkout@v2
    - name: Run style checks
      uses: mibmo/actions-uncrustify@v1
```

Use a specific configuration file via input: 
```yml
on: [ pull_request ]

jobs:
  cpp_style_check:
    runs-on: ubuntu-latest
    name: Check C# Style
    steps:
    - name: Checkout this commit
      uses: actions/checkout@v2
    - name: Run style checks
      uses: mibmo/actions-uncrustify@v1
      with: 
        configPath: 'myConfig.cfg'
```
