PRESENTER_PORT?=8080
PRESENTER_PORT_CONTAINER=80

IMAGE=presenter
TAG=latest
CONTAINER=$(IMAGE)_$(TAG)

PRESENTER_CMD_DOCKER?=docker
BROWSER_ADDR="http://127.0.0.1:$(PRESENTER_PORT)"
OPENER?=$(shell command -v xdg-open || command -v open)

# validate docker command is available
DOCKER=$(shell command -v docker)
ifeq ($(DOCKER),)
$(error Docker command not be found)
endif

# PAGER receives from stdin and uses less paginator if stdout is not a pipe
PAGER={ [ -p /dev/stdout ] || less -F && cat; }


start:    container/start                 ## Start presenter container
stop:     container/stop                  ## Stop presenter container
shell:    container/shell                 ## Shell in presenter container

ps:       container/ps                    ## Show running presenter container
ps/quiet: container/ps/quiet              ## Show only ID os running presenter container

TEMP_TARBALL=$(IMAGE).tgz
export:                                   ## Export presentation for sharing as SFX file ./sfx.run
	@$(MAKE) -e OPENER="echo running at" start \
	&& $(DOCKER) export $(CONTAINER) | gzip -9 > $(TEMP_TARBALL) \
	&& cat ./bin/sfx.sh $(IMAGE).tgz > sfx.run \
	&& rm $(TEMP_TARBALL) \
	&& chmod +x sfx.run

inspect:                                  ## Inspect presenter's image and container
	@{    echo image/inspect:;     $(MAKE) --no-print-directory image/inspect     | cat \
	   && echo container/inspect:; $(MAKE) --no-print-directory container/inspect | cat \
	;} | $(PAGER)

container/start: image/build              ## Docker run container of presenter image
	@$(DOCKER) run --rm -dp $(PRESENTER_PORT):$(PRESENTER_PORT_CONTAINER) \
				--name $(CONTAINER) \
				$(IMAGE):$(TAG) \
	&& $(OPENER) "$(BROWSER_ADDR)"

container/ps:                             ## Docker list presenter container
	@$(DOCKER) ps -f name=$(CONTAINER)

container/ps/quiet:                       ## Docker list only ID of presenter container
	@$(DOCKER) ps -qf name=$(CONTAINER)

.PHONY: container/shell
CMD_SHELL=$(shell $(DOCKER) ps -qf name=$(CONTAINER) --format "$(DOCKER) exec -it {{.ID}} sh")
container/shell:                          ## Docker shell into presenter container
ifneq ($(strip $(CMD_SHELL)),)
	@$(CMD_SHELL)
else
	$(info container is not running: $(CONTAINER))
	@$(MAKE) start && $(MAKE) shell
endif

.PHONY: container/stop
CMD_STOP=$(shell $(DOCKER) ps -qf name=$(CONTAINER) --format "$(DOCKER) stop -t1 {{.ID}}")
container/stop:                           ## Docker stop presenter container
ifneq ($(strip $(CMD_STOP)),)
	@$(CMD_STOP)
else
	$(info container is not running: $(CONTAINER))
endif


.PHONY: image/build
image/build:                              ## Docker build presenter image
	@$(DOCKER) rm -f $(CONTAINER) || true; $(DOCKER) build . --target $(IMAGE) -t $(IMAGE):$(TAG)


.PHONY: image/inspect
image/inspect:                             ## Docker inspect presenter image
	@$(DOCKER) image inspect $(IMAGE):$(TAG) | $(PAGER)
	

.PHONY: container/inspect
CMD_INSPECT=$(shell $(DOCKER) ps -qf name=$(CONTAINER) --format "$(DOCKER) inspect {{.ID}}")
container/inspect:                        ## Docker inspect presenter container
ifneq ($(strip $(CMD_INSPECT)),)
	@$(CMD_INSPECT) | $(PAGER)
else
	$(info container is not running: $(CONTAINER))
endif

.PHONY: help
help:                                     ## Display this help screen
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'