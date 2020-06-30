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

    validicitytool organisation get --help

You can start with getting all organisations:

    validicitytool organisation get

or with verbose output to see what is happening:

    validicitytool organisation get -v

And a single one:

    validicitytool organisation get -i 1

Use `--help` for sub commands to explore possibilities. Use `-v` for verbose output showing URL, headers etc when validicitytool performs calls.

The directory `json` contains sample files to use when creating entities.

# Examples

Create an organisation Foo. First make a `foo.json` file:

    {
        "name": "Foo AB",
        "description": "Foo test organisation",
        "metadata": {}
    }

Then create the organisation:

    validicitytool organisation create -f json/foo.json

Then a project for the organisation, `foo-project.json`:

    {
        "organisation": {"id": 4},
        "name": "Foo Demo Project ",
        "description": "Foo demo project",
        "location": "Europe/Stockholm",
        "metadata": { }
    }

    validicitytool project create -f json/foo-project.json

Create a new user Bob, note the id of the organisation, `bob.json`:

    {
        "username": "bob",
        "password": "bobspass",
        "name": "Bob Smith",
        "organisation": {"id": 4},
        "email": "bob@krampe.se",
        "type": "user"
    }

    validicitytool user create -f json/bob.json

Finally add Bob to this project:

    validicitytool project adduser -p 4 -u 9

And check all users with access to project 4, should list Bob:

    validicitytool project users -p 4

# Using validicitytool with jq
There is a small utility tool called `jq` that can process JSON on stdinput, it's available on Linux and Windows. Using `jq` we can get prettier output and we can more easily use grep and the various features of jq itself.

Show JSON prettified and in colors:

    validicitytool organisation get | jq

More easily use grep since jq formats JSON in lines:

    validicitytool organisation get | jq . | grep "description"

We can also use jq to manipulate JSON, like constructing an array of organisation names for example:

    validicitytool organisation get | jq '[.[] | .name]'

More info here: https://stedolan.github.io/jq/tutorial/