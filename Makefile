#############
# Variables #
#############

COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

########
# Help #
########

default: help

help: ## Display this help message
	@printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	@printf " make [target]\n\n"
	@printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; { \
		printf " ${COLOR_INFO}%-30s${COLOR_RESET} %s\n", $$1, $$2 \
	}'

################
# Dependencies #
################

update: ## Update dependencies
	docker run --rm -v $$(PWD):/site --entrypoint bundle bretfisher/jekyll update

##############
# Containers #
##############

up: ## Bring up docker container
	docker run -p 4000:4000 -v $$(PWD):/site bretfisher/jekyll-serve
