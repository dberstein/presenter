**presenter** - companion to go's tool [present](https://godoc.org/golang.org/x/tools/present).


Presenter wraps `present` tool in a small cutomized [alpine linux](https://alpinelinux.org) image the [present](https://godoc.org/golang.org/x/tools/present) binary, content under `./docroot` can be accessed by a web browser at `http://127.0.0.1:8080` (browser is open automatically).

**Important: [docker](https://www.docker.com) or [podman](https://podman.io) are required**

Default is to open browser URL `http://127.0.0.1:8080`. Override port `8080` with environmental variable **PRESENTER_PORT**, ie. `make run -e PRESENTER_PORT=9999`

A slide bundle is created for each subdirectory of `./docroot`, named `<dir>.slide`, by concatenating directory's `.title` file and alphabetically ordered [.slide](https://golang.org/x/tools/cmd/present) files inside. To manage ordering, please use a naming convention like:

```
./docroot/subject/.title
./docroot/subject/000-intro.slide
./docroot/subject/100-finalwords.slide
./docroot/subject/blog.article
```

Will be bundled and served as if `./docroot` had:
```
./docroot/subject.slide        # concatenation of subject/.title and subject/*.slide
./docroot/subject/blog.article
```

Above naming scheme guarantees `000-intro.slide` will appear in the bundle before `100-final.slide`.

- Directory title file `.title` **must** start as a top level section (ie. `# title`), directories missing a `.title` get default one created using directory's name as title
- Above means that individual slides (`*.slide` files) should start with a subsection `## slide title`
- Non slide files, like above's [.article](https://golang.org/x/blog), are copied and served without modifications
- Organize a mix of `.slide` and `.article` files in hierachical subdirectories for maximum impact.

** Sharing**

Docker image can be exported/saved for sharing (container name is `presenter_local`), to run it need to expose container's port **80** and use as command: `presenter`

```
$ make export # creates ./sfx.run
$ ./sfx.run   # shared sfx.run
```

** Title placeholders **

When `.title` files are processed, the following placeholders are expanded:

|| PLACEHOLDER || REPLACEMENT ||
| TODO | TODO |
| ... | ... |

**Usage:** `make help`

Scenarios:
- Problem: go's present contents of ./docroot
  - Solution: `$ make [start]`
- Problem: serve `./docroot` only for 30 seconds
  - Solution: `$ make [start] && sleep 30 && make stop`
- Problem: docker inspect image and/or running container
  - Solution: `$ make (inspect|image/inspect|container/inspect)`
- Problem: I use `podman` not `docker`
  - Solution: set env var `PRESENTER_CMD_DOCKER=podman` when calling `make` or `sfx.run`
- Problem: need to listen to port different taht `8080`
  - Solution: set env var `PRESENTER_PORT` to port number desired when calling `make` or `sfx.run`
- Problem: need to share presentation
  - Solution: `$ make export` created `./sfx.run` that can be shared, file size will be `~60MB` (note that file is overwritten per invocation, rename/backup as required)
- Problem: need shell access to running container.
  - Solution: `$ make shell`
```
$  make shell
/docroot # 
```
