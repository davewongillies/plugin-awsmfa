<img src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" width="144px" height="144px"/>

#### awsmfa
> A plugin for [Oh My Fish][omf-link].

[![Fish Shell Version](https://img.shields.io/badge/fish-v2.6.0-007EC7.svg?style=flat-square)](http://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-007EC7.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)
[![license](https://img.shields.io/github/license/davewongillies/plugin-awsmfa.svg)]()

<br/>

Gets and sets temporary credentials for an AWS account or IAM user when using an [MFA-enabled account](http://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html).


## Install

```fish
$ omf install https://github.com/davewongillies/plugin-awsmfa
```

## Configuration
In `~/.aws/credentials`, add `username` and `account_id` settings to each profile that you want to use `awsmfa` with.

## Usage

```fish
$ awsmfa                  Generates temporary credentials for the default aws profile
$ awsmfa [profile_name]   Generates temporary credentials for the aws profile of a provided name
```

`awsmfa` sets the env var `$AWS_SESSION_EXPIRY`, so running `awsmfa` again will only prompt for a token is its expired. Run the function `__awsmfa_clear_variables` if you want to clear them.

```fish
$ awsmfa
AWS_SESSION_TOKEN is still valid but will expire at 2017-12-01T06:14:57Z
```


# License

© [David Gillies][author] et [al][contributors]


[author]:         http://github.com/davewongillies
[contributors]:   https://github.com/davewongillies/plugin-awsmfa/graphs/contributors
[omf-link]:       https://www.github.com/oh-my-fish/oh-my-fish
