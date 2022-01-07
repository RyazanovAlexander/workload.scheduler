

# ------------------------------------------------------------------------------
#  deploy

.PHONY: deploy
deploy:
	@skaffold dev --port-forward --no-prune=false --cache-artifacts=false

# ------------------------------------------------------------------------------
#  clear

.PHONY: clear
clear:
	@skaffold delete