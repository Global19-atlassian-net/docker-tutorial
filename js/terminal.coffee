###
  Please note the javascript is being fully generated from coffeescript.
  So make your changes in the .coffee file.
  Thatcher Peskens
         _
      ,_(')<
      \___)

###

do @myTerminal = ->

  #  id = terminal

  @basesettings = {
    prompt: 'you@tutorial:~$ ',
    greetings: """Welcome to the interactive Docker tutorial"""

  }

  ###
    Callback definitions. These can be overridden by functions anywhere else
  ###

  @preventDefaultCallback = false

  @immediateCallback = (command) ->
    console.debug("immediate callback from #{command}")
    return

  @finishedCallback = (command) ->
    console.debug("finished callback from #{command}")
    return

  @intermediateResults = (string) ->
    console.debug("sent #{string}")
    return

  ###
    Base interpreter
  ###

  @interpreter = (input, term) ->
    inputs = input.split(" ")
    command = inputs[0]

    if command is 'hi'
      term.echo 'hi there! What is your name??'
      term.push (command, term) ->
        term.echo command + ' is a pretty name'

    if command is 'shell'
      term.push (command, term) ->
        if command is 'cd'
          bash(term, inputs)
      , {prompt: '> $ '}

    if command is 'r'
      location.reload('forceGet')

    if command is '#'
      term.echo 'which question?'

    if command is 'test'
      term.echo 'ok'
      arrA = ['aap', 'noot', 'rat']
      arrB = ['aap', 'noot', 'mies']

      valid = arrA.every( (value) ->
#        term.echo value
#        term.echo arrB.indexOf(value)
        if arrB.indexOf(value) == -1
          term.echo value.indexOf(arrB)
          term.echo value
          return false
        else
          return true
      )

      term.echo valid

    if command is 'cd'
      bash(term, inputs)

    if command is 'exec'
      term.exec (
        "docker run"
      )

    if command is "help"
      term.error 'printing help'
      term.echo '[[b;#fff;]some text]'

    if command is "docker"
      docker(term, inputs)

    if command is "colors"
      for dockerCommand, description of dockerCommands
        term.echo ("[[b;#fff;]" + dockerCommand + "] - " + description + "")

    if command is "pull"
      term.echo '[[b;#fff;]some text]'
      wait(term, 5000, true)
      alert term.get_output()

      return

  #  $('#terminal').terminal( interpreter, basesettings )
    immediateCallback(inputs)
#    immediateCallback(parseInput(inputs))

  ###
    Common utils
  ###

  String.prototype.beginsWith = (string) ->
    ###
    Check if 'this' string starts with the inputstring.
    ###
    return(this.indexOf(string) is 0)

  Array.prototype.containsAllOfThese = (inputArr) ->
    ###
    This function compares all of the elements in the inputArr
    and checks them one by one if they exist in 'this'. When it
    finds an element to not exist, it returns false.
    ###
    me = this
    valid = false

    if inputArr
      valid = inputArr.every( (value) ->
        if me.indexOf(value) == -1
          return false
        else
          return true
      )

    return valid

  parseInput = (inputs) ->
    command = inputs[1]
    switches = []
    switchArg = false
    switchArgs = []
    imagename = ""
    commands = []
    j = 0

    # parse args
    for input in inputs
      if input.startsWith('-') and imagename == ""
        switches.push(input)
        if switches.length > 0
          switchArg = true
      else if switchArg == true
        # reset switchArg
        switchArg = false
        switchArgs.push(input)
      else if j > 1 and imagename == ""
        # match wrong names
        imagename = input
      else if imagename != ""
        commands.push (input)
      else
        # nothing?
      j++

    parsed_input = {
      'switches': switches.sortBy(),
      'switchArgs': switchArgs,
      'imageName': imagename,
      'commands': commands,
    }
    return parsed_input


  util_slow_lines = (term, paragraph, keyword, finishedCallback) ->

    if keyword
      lines = paragraph(keyword).split("\n")
    else
      lines = paragraph.split("\n")

    term.pause()
    i = 0
    # function calls itself after timeout is done, untill
    # all lines are finished
    foo = (lines) ->
      self.setTimeout ( ->
        if lines[i]
          term.echo (lines[i])
          i++
          foo(lines)
        else
          term.resume()
          finishedCallback()
      ), 1000

    foo(lines)



  wait = (term, time, dots) ->
    term.echo "starting to wait"
    interval_id = self.setInterval ( -> dots ? term.insert '.'), 500

    self.setTimeout ( ->
      self.clearInterval(interval_id)
      output = term.get_command()
      term.echo output
      term.echo "done "
    ), time

  ###
    Bash program
  ###

  bash = (term, inputs) ->
    echo = term.echo
    insert = term.insert

    if not inputs[1]
      console.log("none")

    else
      argument = inputs[1]
      if argument.beginsWith('..')
        echo "-bash: cd: #{argument}: Permission denied"
      else
        echo "-bash: cd: #{argument}: No such file or directory"

  ###
    Docker program
  ###
  docker = (term, inputs) ->

    echo = term.echo
    insert = term.insert
    callback = () -> @finishedCallback(inputs)
    command = inputs[1]

    # no command
    if not inputs[1]
      console.debug "no args"
      echo docker_cmd
      for dockerCommand, description of dockerCommands
        echo "[[b;#fff;]" + dockerCommand + "]" + description + ""

    else if inputs[1] is "do"
      term.push('do', {prompt: "do $ "})

    # command ps
    else if command is "ps"
      if inputs.containsAllOfThese(['-a', '-l'])
        echo ps_a_l
      else
        echo ps

    # Command commit
    else if inputs[1] is "commit"
      if inputs[2] is '6982a9948422' and inputs[3]
        util_slow_lines(term, commit_containerid, "", callback )
      else if inputs[2] is '6982a9948422'
        util_slow_lines(term, commit_containerid, "", callback )
        intermediateResults(0)
      else
        echo commit


    # Command run
    else if inputs[1] is "run"
      # parse all input so we have a json object
      parsed_input = parseInput(inputs)

      switches = parsed_input.switches
      swargs = parsed_input.switchArgs
      imagename = parsed_input.imageName
      commands = parsed_input.commands

      #check the args
      expected_switches = ['-i', '-t']

      console.log "commands"
      console.log commands

      console.log imagename

      if imagename is "ubuntu"
        console.log("run ubuntu")
        echo run_image_wrong_command(commands[0])
#      else if switches.containsAllOfThese(expected_switches)
#        if imagename is "learn/tutorial" and commands[0] is "/bin/bash"
#          immediateCallback(parsed_input, true)
#          term.push ( (command, term) ->
#            if command
#              echo """this shell is not implemented. Enter 'exit' to exit."""
#            return
#          ), {prompt: 'root@687bbbc4231b:/# '}
#        else
#          intermediateResults(1)
      else if imagename is "learn/tutorial"
        if switches.length > 0
          echo run_learn_no_command
          intermediateResults(0)
        else if commands[0] is "/bin/bash"
          echo run_learn_tutorial_echo_hello_world
          intermediateResults(2)
        else if commands[0] is "echo"
          echo run_learn_tutorial_echo_hello_world
        else if commands.containsAllOfThese(['apt-get', 'install', '-y', 'iputils-ping'])
          echo run_apt_get_install_iputils_ping
        else if commands.containsAllOfThese(['apt-get', 'install', 'iputils-ping'])
          echo run_apt_get_install_iputils_ping
          intermediateResults(0)
        else if commands.containsAllOfThese(['apt-get', 'install', 'ping'])
          echo run_apt_get_install_iputils_ping
          intermediateResults(0)
        else if commands[0] is "apt-get"
          echo run_apt_get
        else if commands[0]
          echo run_image_wrong_command(commands[0])
        else
          echo run_learn_no_command

      else if imagename is "learn/ping"
        if commands.containsAllOfThese(["ping", "www.google.com"])
          util_slow_lines(term, run_ping_www_google_com, "", callback )


      else if imagename
        echo run_notfound(inputs[2])
      else
        console.log("run")
        echo run_cmd


    else if inputs[1] is "search"
      if keyword = inputs[2]
        if keyword is "ubuntu"
          echo search_ubuntu
        else if keyword is "tutorial"
          echo search_tutorial
        else
          echo search_no_results(inputs[2])
      else echo search

    else if inputs[1] is "pull"
      if keyword = inputs[2]
        if keyword is 'ubuntu'
          result = util_slow_lines(term, pull_ubuntu, "", callback )
        else if keyword is 'learn/tutorial'
          result = util_slow_lines(term, pull_tutorial, "", callback )
        else
          util_slow_lines(term, pull_no_results, keyword)
      else
        echo pull

    else if inputs[1] is "version"
      echo (version)


    else if dockerCommands[inputs[1]]
      echo "#{inputs[1]} is a valid argument, but not implemented"

    # return empty value because otherwise coffeescript will return last var
    return

  ###
    Some default variables / commands

    All items are sorted by alphabet
  ###

  docker_cmd = \
    """
      Usage: docker [OPTIONS] COMMAND [arg...]
      -H="127.0.0.1:4243": Host:port to bind/connect to

      A self-sufficient runtime for linux containers.

      Commands:

    """

  dockerCommands =
    "attach": "    Attach to a running container"
    "build": "     Build a container from a Dockerfile"
    "commit": "    Create a new image from a container's changes"
    "diff": "      Inspect changes on a container's filesystem"
    "export": "    Stream the contents of a container as a tar archive"
    "history": "   Show the history of an image"
    "images": "    List images"
    "import": "    Create a new filesystem image from the contents of a tarball"
    "info": "      Display system-wide information"
    "insert": "    Insert a file in an image"
    "inspect": "   Return low-level information on a container"
    "kill": "      Kill a running container"
    "login": "     Register or Login to the docker registry server"
    "logs": "      Fetch the logs of a container"
    "port": "      Lookup the public-facing port which is NAT-ed to PRIVATE_PORT"
    "ps": "        List containers"
    "pull": "      Pull an image or a repository from the docker registry server"
    "push": "      Push an image or a repository to the docker registry server"
    "restart": "   Restart a running container"
    "rm": "        Remove a container"
    "rmi": "       Remove an image"
    "run": "       Run a command in a new container"
    "search": "    Search for an image in the docker index"
    "start": "     Start a stopped container"
    "stop": "      Stop a running container"
    "tag": "       Tag an image into a repository"
    "version": "   Show the docker version information"
    "wait": "      Block until a container stops, then print its exit code"

  run_switches =
    "-p": ['port']
    "-t": []
    "-i": []
    "-h": ['hostname']

  commit = \
    """
    Usage: docker commit [OPTIONS] CONTAINER [REPOSITORY [TAG]]

    Create a new image from a container's changes

      -author="": Author (eg. "John Hannibal Smith <hannibal@a-team.com>"
      -m="": Commit message
      -run="": Config automatically applied when the image is run. (ex: {"Cmd": ["cat", "/world"], "PortSpecs": ["22"]}')
    """

  commit_id_does_not_exist = (keyword) ->
    """
    2013/07/08 23:51:21 Error: No such container: #{keyword}
    """

  commit_containerid = \
    """
    effb66b31edb
    """

  ps = \
    """
    ID                  IMAGE                                  COMMAND                CREATED             STATUS              PORTS
    e087bc23f8d5        dhrp/dockerbuilder-test-29414:latest   ping orange1.koffied   2 days ago          Up 2 days           49156->80
    fca0152982a0        dhrp/dockerbuilder-test-02959:latest   ping orange1.koffied   2 days ago          Up 2 days
    ebd8c2aaeed3        dhrp/dockerbuilder-test-02959:latest   ping orange1.koffied   2 days ago          Up 2 days
    1a93e427d337        crosbymichael/dockerui:latest          /dockerui -e=http://   3 days ago          Up 3 days           49153->9000
    880f3a93a0f7        dhrp/dockerbuilder-test-02959:latest   ping orange1.koffied   3 days ago          Up 3 days
    """

  ps_a_l = \
    """
    ID                  IMAGE               COMMAND                CREATED             STATUS              PORTS
    6982a9948422        ubuntu:12.04        apt-get install ping   1 minute ago        Exit 0
    """

  pull = \
    """
    Usage: docker pull NAME

    Pull an image or a repository from the registry

    -registry="": Registry to download from. Necessary if image is pulled by ID
    -t="": Download tagged image in repository
    """

  pull_no_results = (keyword) ->
    """
    Pulling repository #{keyword} from https://index.docker.io/v1
    2013/06/19 19:27:03 HTTP code: 404
    """

  pull_ubuntu =
    """
    Pulling repository ubuntu from https://index.docker.io/v1
    Pulling image 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c (precise) from ubuntu
    Pulling image b750fe79269d2ec9a3c593ef05b4332b1d1a02a62b4accb2c21d589ff2f5f2dc (12.10) from ubuntu
    Pulling image 27cf784147099545 () from ubuntu
    """

  pull_tutorial = \
    """
    Pulling repository learn/tutorial from https://index.docker.io/v1
    Pulling image 8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c (precise) from ubuntu
    Pulling image b750fe79269d2ec9a3c593ef05b4332b1d1a02a62b4accb2c21d589ff2f5f2dc (12.10) from ubuntu
    Pulling image 27cf784147099545 () from tutorial
    """

  run_cmd = \
    """
    Usage: docker run [OPTIONS] IMAGE COMMAND [ARG...]

    Run a command in a new container

    -a=map[]: Attach to stdin, stdout or stderr.
    -c=0: CPU shares (relative weight)
    -d=false: Detached mode: leave the container running in the background
    -dns=[]: Set custom dns servers
    -e=[]: Set environment variables
    -h="": Container host name
    -i=false: Keep stdin open even if not attached
    -m=0: Memory limit (in bytes)
    -p=[]: Expose a container's port to the host (use 'docker port' to see the actual mapping)
    -t=false: Allocate a pseudo-tty
    -u="": Username or UID
    -v=map[]: Attach a data volume
    -volumes-from="": Mount volumes from the specified container

    """

  run_apt_get = \
    """
    apt 0.8.16~exp12ubuntu10 for amd64 compiled on Apr 20 2012 10:19:39
    Usage: apt-get [options] command
           apt-get [options] install|remove pkg1 [pkg2 ...]
           apt-get [options] source pkg1 [pkg2 ...]

    apt-get is a simple command line interface for downloading and
    installing packages. The most frequently used commands are update
    and install.

    Commands:
       update - Retrieve new lists of packages
       upgrade - Perform an upgrade
       install - Install new packages (pkg is libc6 not libc6.deb)
       remove - Remove packages
       autoremove - Remove automatically all unused packages
       purge - Remove packages and config files
       source - Download source archives
       build-dep - Configure build-dependencies for source packages
       dist-upgrade - Distribution upgrade, see apt-get(8)
       dselect-upgrade - Follow dselect selections
       clean - Erase downloaded archive files
       autoclean - Erase old downloaded archive files
       check - Verify that there are no broken dependencies
       changelog - Download and display the changelog for the given package
       download - Download the binary package into the current directory

    Options:
      -h  This help text.
      -q  Loggable output - no progress indicator
      -qq No output except for errors
      -d  Download only - do NOT install or unpack archives
      -s  No-act. Perform ordering simulation
      -y  Assume Yes to all queries and do not prompt
      -f  Attempt to correct a system with broken dependencies in place
      -m  Attempt to continue if archives are unlocatable
      -u  Show a list of upgraded packages as well
      -b  Build the source package after fetching it
      -V  Show verbose version numbers
      -c=? Read this configuration file
      -o=? Set an arbitrary configuration option, eg -o dir::cache=/tmp
    See the apt-get(8), sources.list(5) and apt.conf(5) manual
    pages for more information and options.
                           This APT has Super Cow Powers.

    """

  run_apt_get_install_iputils_ping = \
    """
    Reading package lists...
    Building dependency tree...
    The following NEW packages will be installed:
      iputils-ping
    0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
    Need to get 56.1 kB of archives.
    After this operation, 143 kB of additional disk space will be used.
    Get:1 http://archive.ubuntu.com/ubuntu/ precise/main iputils-ping amd64 3:20101006-1ubuntu1 [56.1 kB]
    debconf: delaying package configuration, since apt-utils is not installed
    Fetched 56.1 kB in 1s (50.3 kB/s)
    Selecting previously unselected package iputils-ping.
    (Reading database ... 7545 files and directories currently installed.)
    Unpacking iputils-ping (from .../iputils-ping_3%3a20101006-1ubuntu1_amd64.deb) ...
    Setting up iputils-ping (3:20101006-1ubuntu1) ...
    """

  run_learn_no_command = \
    """
    2013/07/02 02:00:59 Error: No command specified
    """

  run_learn_tutorial_echo_hello_world = \
    """
    hello world
    """

  run_image_wrong_command = (keyword) ->
    """
    2013/07/08 23:13:30 Unable to locate #{keyword}
    """

  run_notfound = (keyword) ->
    """
    Pulling repository #{keyword} from https://index.docker.io/v1
    2013/07/02 02:14:47 Error: No such image: #{keyword}
    """

  run_ping_www_google_com = \
    """
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=1 ttl=55 time=2.23 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=2 ttl=55 time=2.30 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=3 ttl=55 time=2.27 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=4 ttl=55 time=2.30 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=5 ttl=55 time=2.25 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=6 ttl=55 time=2.29 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=7 ttl=55 time=2.23 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=8 ttl=55 time=2.30 ms
    64 bytes from nuq05s02-in-f20.1e100.net (74.125.239.148): icmp_req=9 ttl=55 time=2.35 ms
    -> This would normally just keep going. However, this emulator does not support Ctrl-C, so we quit here.
    """

  search = \
    """

    Usage: docker search NAME

    Search the docker index for images

    """

  search_no_results = (keyword) ->
    """
    Found 0 results matching your query ("#{keyword}")
    NAME                DESCRIPTION
    """

  search_tutorial = \
    """
    Found 1 results matching your query ("tutorial")
    NAME                      DESCRIPTION
    learn/tutorial            An image for the interactive tutorial
    """

  search_ubuntu = \
    """
    Found 22 results matching your query ("ubuntu")
    NAME                DESCRIPTION
    shykes/ubuntu
    base                Another general use Ubuntu base image. Tag...
    ubuntu              General use Ubuntu base image. Tags availa...
    boxcar/raring       Ubuntu Raring 13.04 suitable for testing v...
    dhrp/ubuntu
    creack/ubuntu       Tags:
    12.04-ssh,
    12.10-ssh,
    12.10-ssh-l...
    crohr/ubuntu              Ubuntu base images. Only lucid (10.04) for...
    knewton/ubuntu
    pallet/ubuntu2
    erikh/ubuntu
    samalba/wget              Test container inherited from ubuntu with ...
    creack/ubuntu-12-10-ssh
    knewton/ubuntu-12.04
    tithonium/rvm-ubuntu      The base 'ubuntu' image, with rvm installe...
    dekz/build                13.04 ubuntu with build
    ooyala/test-ubuntu
    ooyala/test-my-ubuntu
    ooyala/test-ubuntu2
    ooyala/test-ubuntu3
    ooyala/test-ubuntu4
    ooyala/test-ubuntu5
    surma/go                  Simple augmentation of the standard Ubuntu...

    """

  version = \
  """
    Docker Emulator version 0.1

    Emulating:
    Client version: 0.4.7
    Server version: 0.4.7
    Go version: go1.1
    """



return this


