# Validitytool
This is the CLI administration tool for the Validicity system.It communicates with the Validicity server via a REST API, authenticated using OAuth2.

# Install
Run the following:

    ./build.sh

If all worked you should be able to run `validicitytool` and see help output.

After this you can edit the `validicitytool.conf` file with the proper settings to reach the correct Validicity server.

# Use
Validicitytool has decent help included for all options and commands, just add `--help` at the end:

    validicitytool --help

or:

    validicitytool customer get --help

You can start with getting all customers:

    validicitytool customer get

or with verbose output to see what is happening:

    validicitytool customer get -v

And a single one:

    validicitytool customer get -i 1

Use `--help` for sub commands to explore possibilities. Use `-v` for verbose output showing URL, headers etc when validicitytool performs calls.

The directory `json` contains sample files to use when creating entities.

# Using validicitytool with jq
There is a small utility tool called `jq` that can process JSON on stdinput, it's available on Linux and Windows. Using `jq` we can get prettier output and we can more easily use grep and the various features of jq itself.

Show JSON prettified and in colors:

    validicitytool customer get | jq

More easily use grep since jq formats JSON in lines:

    validicitytool customer get | jq . | grep "version"

We can also use jq to manipulate JSON, like constructing an array of customer names for example:

    validicitytool customer get | jq '[.[] | .name]'

More info here: https://stedolan.github.io/jq/tutorial/