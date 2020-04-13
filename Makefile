PRESENTER_HOST?=127.0.0.1
PRESENTER_PORT?=8080
PRESENTER_CMD?=docker
PRESENTER_OPENER?=$(shell command -v xdg-open || command -v open)
PRESENTER_EXPORT?=sfx.run

PRESENTER_IMAGE=presenter
PRESENTER_TAG=latest
PRESENTER_PORT_CONTAINER=80
PRESENTER_CONTAINER=$(PRESENTER_IMAGE)_$(PRESENTER_TAG)
PRESENTER_URL=http://$(PRESENTER_HOST):$(PRESENTER_PORT)

# validate PRESENTER_CMD command is available
CMD=$(shell command -v $(PRESENTER_CMD))
ifeq ($(CMD),)
$(error command not be found: $(CMD))
endif

# PAGER receives from stdin and uses less paginator if stdout is not a pipe
PAGER={ [ -p /dev/stdout ] || less -F && cat; }

# BOLD arguments
BOLD=$(shell tput bold)$(strip $1$2$3$4$5$6$7$8$9$(shell tput sgr0))

## TARGETS FOLLOW ...
.PHONY: help info \
		start stop shell ps ps/quiet export inspect \
		image/build image/inspect \
		container/inspect container/start container/ps container/ps/quiet container/shell container/stop

start:    container/start                 ## Start presenter container

stop:     container/stop                  ## Stop presenter container

shell:    container/shell                 ## Shell in presenter container

ps:       container/ps                    ## Show running presenter container

ps/quiet: container/ps/quiet              ## Show only ID os running presenter container

export:                                   ## Export presentation for sharing as SFX file ./sfx.run
	@$(MAKE) -e PRESENTER_OPENER="echo running at" start \
	&& { \
		cat ./bin/sfx.sh && $(CMD) export $(PRESENTER_CONTAINER) | gzip -9; \
	} > $(PRESENTER_EXPORT) \
	&& echo "Exported: $(call BOLD,$(PRESENTER_EXPORT))"

inspect:                                  ## Inspect presenter's image and container
	@{   echo image/inspect: \
	  && $(MAKE) --no-print-directory image/inspect | cat \
	  && echo container/inspect: \
	  && $(MAKE) --no-print-directory container/inspect | cat; \
	} | $(PAGER)

container/start: image/build              ## Run container of presenter image
	@$(CMD) run --rm -dp $(PRESENTER_PORT):$(PRESENTER_PORT_CONTAINER) \
				--name $(PRESENTER_CONTAINER) \
				$(PRESENTER_IMAGE):$(PRESENTER_TAG) \
	&& echo "Presenter address: $(call BOLD,$(PRESENTER_URL))" \
	&& $(PRESENTER_OPENER) "$(PRESENTER_URL)" 2>&1 >/dev/null

container/ps:                             ## List presenter container
	@$(CMD) ps -f name=$(PRESENTER_CONTAINER)

container/ps/quiet:                       ## List only ID of presenter container
	@$(CMD) ps -qf name=$(PRESENTER_CONTAINER)

CMD_SHELL=$(shell $(CMD) ps -qf name=$(PRESENTER_CONTAINER) --format "$(CMD) exec -it {{.ID}} sh")
container/shell:                          ## Shell in presenter container
ifneq ($(strip $(CMD_SHELL)),)
	@$(CMD_SHELL)
else
	$(info container is not running: $(PRESENTER_CONTAINER))
	@$(MAKE) start && $(MAKE) shell
endif

CMD_STOP=$(shell $(CMD) ps -qf name=$(PRESENTER_CONTAINER) --format "$(CMD) stop -t1 {{.ID}}")
container/stop:                           ## Stop presenter container
ifneq ($(strip $(CMD_STOP)),)
	@echo "$(call BOLD,Stopping...) $(shell $(CMD_STOP))"
else
	$(error container is not running: $(PRESENTER_CONTAINER))
endif

image/build:                              ## Build presenter image
	@$(CMD) rm -f $(PRESENTER_CONTAINER) || true; $(CMD) build . --target $(PRESENTER_IMAGE) -t $(PRESENTER_IMAGE):$(PRESENTER_TAG)

image/inspect:                             ## Inspect presenter image
	@$(CMD) image inspect $(PRESENTER_IMAGE):$(PRESENTER_TAG) | $(PAGER)

CMD_INSPECT=$(shell $(CMD) ps -qf name=$(PRESENTER_CONTAINER) --format "$(CMD) inspect {{.ID}}")
container/inspect:                        ## Inspect presenter container
ifneq ($(strip $(CMD_INSPECT)),)
	@$(CMD_INSPECT) | $(PAGER)
else
	$(info container is not running: $(PRESENTER_CONTAINER))
endif

info:                                     ## Display env vars info
	@  echo PRESENTER_HOST=$(PRESENTER_HOST) \
	&& echo PRESENTER_PORT=$(PRESENTER_PORT) \
	&& echo PRESENTER_CMD=$(CMD) \
	&& echo PRESENTER_PORT_CONTAINER=$(PRESENTER_PORT_CONTAINER) \
	&& echo PRESENTER_OPENER=$(PRESENTER_OPENER) \
	&& echo PRESENTER_EXPORT=$(PRESENTER_EXPORT) \
	&& echo PRESENTER_IMAGE=$(PRESENTER_IMAGE) \
	&& echo PRESENTER_TAG=$(PRESENTER_TAG) \
	&& echo PRESENTER_CONTAINER=$(PRESENTER_CONTAINER) \
	&& echo PRESENTER_URL=$(PRESENTER_URL)

help:                                     ## Display this help screen
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
