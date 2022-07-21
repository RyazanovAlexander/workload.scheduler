CONTENT    := justfile_directory() + "/content"
DEPLOY     := justfile_directory() + "/deploy"
COMMIT_TAG := `date "+%Y-%m-%dT%H:%M:%S"`

# This list of available targets.
default:
    @just --list

# 1.
run:
	@echo "1"

# Build local content to public directory.
build:
	@echo "Generating site..."
	@cd {{CONTENT}} && hugo --quiet --minify --gc --cleanDestinationDir --destination {{DEPLOY}}
	@cp {{CONTENT}}/CNAME {{DEPLOY}}
	@echo "Done"

# 1.
publish:
	@echo "1"

# 2.
local deploy:
	@echo "2"
#	@skaffold dev --port-forward --no-prune=false --cache-artifacts=false

# 3.
local delete:
	@echo "3"
#	@skaffold delete