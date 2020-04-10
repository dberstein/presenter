**presenter** - companion to go's present tool.

Presenter wraps go's [present](https://godoc.org/golang.org/x/tools/present) tool by building and running in a small cutomized alpine linux image, go's present, and open web browser at local listening port of tool's web UI content inside `./docroot`.

**Important: Docker is required**

A bundle slide is created for each subdirectory of `./docroot`, named `<dir>.slide`, by concatenating directory's `.title` file and alphabetically ordered [.slide](https://golang.org/x/tools/cmd/present) files inside. To manage ordering, please use a naming convention like:

- `./docroot/subject/.title`
- `./docroot/subject/000-intro.slide`
- `./docroot/subject/100-finalwords.slide`
- `./docroot/subject/blog.article`

Will be bundled and served as if `./docroot` had:
- `./docroot/subject.slide`
- `./docroot/subject/blog.article`

Non-slide files, like above's [.article](https://golang.org/x/blog), are copied and served verbatim. Organize a mix of `.slide` and `.article` files in hierachical subdirectories for maximum impact.

Above guarantees `intro` will appear in the bundle before `final`.  

By default browser opens at URL `http://127.0.0.1:8080`. Override port `8080` with environmental variable **EXPOSE_AT**, ie. `make run -e EXPOSE_AT=9999`

*TODO: explain use of placeholders in `.title` files.*

Docker image can be exported/saved for sharing (container name is `presenter_local`), to run it need to expose container's port **80** and use as command: `presenter`

```
$ docker export presenter_local > presentation.tar
$ docker import presentation.tar shared
$ docker run -p 1080:80 shared presenter
```

**Usage:** `make help`

Scenarios:
- Problem: go's present contents of ./docroot
  - Solution: `$ make [start]`
- Problem: serve `./docroot` only for 30 seconds
  - Solution: `$ make [start] && sleep 30 && make stop`
- Problem: docker inspect image and/or running container
  - Solution: `make (inspect|image/inspect|container/inspect)`
- Problem: need shell access to running container.
  - Solution: `make shell`

```
$  make shell
/docroot # 
```
