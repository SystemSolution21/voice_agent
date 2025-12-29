.PHONY: bootstrap install-web install-ts install-py build-web dev-web start-ts start-py dev-ts dev-py clean help

# Paths
WEB_DIR := voice-agent/frontend/web
TS_BACKEND_DIR := voice-agent/backend/typescript
PY_BACKEND_DIR := voice-agent/backend/python

##= Installation

bootstrap: install-web install-ts install-py

install-web:
	cd $(WEB_DIR) && pnpm install

install-ts:
	cd $(TS_BACKEND_DIR) && pnpm install

install-py:
	cd $(PY_BACKEND_DIR) && uv sync --dev

##= Web Build

build-web:
	cd $(WEB_DIR) && pnpm build

dev-web:
	cd $(WEB_DIR) && pnpm build --watch

##= Development (web watch + server)

dev-ts:
	@echo "Starting web build watcher and frontend server..."
	@trap 'kill 0' EXIT; \
		(cd $(WEB_DIR) && pnpm build --watch) & \
		sleep 2 && cd $(TS_BACKEND_DIR) && pnpm run server

dev-py:
	@echo "Starting web build watcher and backend server..."
	@trap 'kill 0' EXIT; \
		(cd $(WEB_DIR) && pnpm build --watch) & \
		sleep 2 && cd $(PY_BACKEND_DIR) && uv run src/main.py

##= Server Only

start-ts: build-web
	cd $(TS_BACKEND_DIR) && pnpm run server

start-py: build-web
	cd $(PY_BACKEND_DIR) && uv run src/main.py

##= Utilities

clean:
	rm -rf $(WEB_DIR)/dist
	rm -rf $(WEB_DIR)/node_modules
	rm -rf $(TS_BACKEND_DIR)/node_modules
	rm -rf $(PY_BACKEND_DIR)/.venv

check-web:
	cd $(WEB_DIR) && pnpm check

check-ts:
	cd $(TS_BACKEND_DIR) && pnpm run typecheck

check: check-web check-ts

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
