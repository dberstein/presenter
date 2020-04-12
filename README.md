# presenter 

> Companion to go's tool [present](https://godoc.org/golang.org/x/tools/present)

## Summary

Presenter wraps `present` tool in a small cutomized [alpine linux](https://alpinelinux.org) image the **present** binary. Content under `./docroot` can be accessed by a web browser launched automatically. Default address is `http://127.0.0.1:8080`.

### Supports

- [docker](https://www.docker.com)
- [podman](https://podman.io)

## Description

Default is to open browser URL `http://127.0.0.1:8080`. Override port `8080` with environmental variable **PRESENTER_PORT**, ie. `make run -e PRESENTER_PORT=9999`

A slide bundle is created for each subdirectory of `./docroot`, named `<dir>.slide`, by concatenating directory's `.title` file and alphabetically ordered [.slide](https://golang.org/x/tools/cmd/present) files inside. If `<dir>.article` doesn't exists its created as a copy of `<dir>.slide`.

To manage ordering, please use a naming convention like:

```
./docroot/subject/.title
./docroot/subject/000-intro.slide
./docroot/subject/100-finalwords.slide
./docroot/subject/blog.article
```

Will be bundled and served as if `./docroot` had:

```
./docroot/subject.slide        # concatenation of subject/.title and subject/*.slide
./docroot/subject.article      # copy of subject.slide
./docroot/subject/blog.article
```

Above naming scheme guarantees `000-intro` will appear in the bundle before `100-final`.

- Directory title file `.title` must start as a top level section (ie. `# title`), directories missing a `.title` get default one created using directory's name as title
- Above means that individual slides (`*.slide` files) should start with a subsection `## slide title`
- Non slide files, like above's *[blog.article](https://golang.org/x/blog)*, are copied and served without modifications
- Slide bundles are also served as `<dir>.article` if there is no such existing article.
- Organize a mix of `.slide` and `.article` files in hierachical subdirectories for maximum impact.

## Usage: `make help`

### Environment variables

Env. Variable    | Description                       | Default Value
-----------------|-----------------------------------|--------------
PRESENTER_CMD    | Command to manage image/container | `docker`
PRESENTER_HOST   | Host name address part to listen  | `127.0.0.1`
PRESENTER_PORT   | Port of address to listen         | `8080`
PRESENTER_OPENER | Preferred application opener      | `xdg-open` or `open`
PRESENTER_EXPORT | Exported filename                 | `sfx.run`

## Sharing

Docker image can be exported/saved for sharing (container name is `presenter_local`), to run it need to expose container's port *80* and use as command: `presenter`

```
# export creates sfx.run
$ make export
... share sfx.run ...
# run shared sfx.run
$ sh sfx.run
```

### Title placeholders

Tile files `.title` have the following placeholders expanded:

PLACEHOLDER        | VALUE
------------------ | -----
`{{DIR}}`          | Directory name
`{{PATH}}`         | Path relative to docroot
`{{FULLPATH}}`     | Absolute directory path
`{{CURRENT_DATE}}` | Current date

Example (file: `./docroot/subject/.title`):
```
# Subject Title: {{DIR}}

This file is in {{PATH}} ({{FULLPATH}}) at {{CURRENT_DATE}}
```
Renders as:
```
Subject Title: subject
Author Name
dow, dd MMM YYYY HH:mm:ss UTC
This file is in [path=subject|fullpath=/docroot/subject]
```

### Scenarios

- Problem: go's present contents of ./docroot
  - Solution: `$ make [start]`
- Problem: serve `./docroot` only for 30 seconds
  - Solution: `$ make [start] && sleep 30 && make stop`
- Problem: docker inspect image and/or running container
  - Solution: `$ make (inspect|image/inspect|container/inspect)`
- Problem: I use `podman` not `docker`
  - Solution: set env var `PRESENTER_CMD=podman` when calling `make` or `sfx.run`
- Problem: need to listen to port different taht `8080`
  - Solution: set env var `PRESENTER_PORT` to port number desired when calling `make` or `sfx.run`
- Problem: need to share presentation
  - Solution: `$ make export` creates `./sfx.run` that can be shared and executed by `sh sfx.run`, file size will be `~60MB` (note that file is overwritten per invocation, rename/backup as required)
- Problem: need shell access to running container.
  - Solution: **`$ make shell`**

    ```
    $  make shell
    /docroot #
    ```
