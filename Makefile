.PHONY: bootstrap install-web install-ts install-py build-web dev-web start-ts start-py dev-ts dev-py clean

##= Installation

bootstrap: install-web install-ts install-py

install-web:
	cd voice-agent/frontend/web && pnpm install

install-ts:
	cd voice-agent/backend/typescript && pnpm install

install-py:
	cd voice-agent/backend/python && uv sync --dev

##= Web Build

build-web:
	cd voice-agent/frontend/web && pnpm build

# Watch mode for web - rebuilds on changes
dev-web:
	cd voice-agent/frontend/web && pnpm build --watch

##= Development (web watch + server)

# frontend server with web watch
dev-ts:
	@echo "Starting web build watcher and frontend server..."
	@trap 'kill 0' EXIT; \
		(cd voice-agent/frontend/web && pnpm build --watch) & \
		sleep 2 && cd voice-agent/backend/typescript && pnpm run server

# backend server with web watch
dev-py:
	@echo "Starting web build watcher and backend server..."
	@trap 'kill 0' EXIT; \
		(cd voice-agent/frontend/web && pnpm build --watch) & \
		sleep 2 && cd voice-agent/backend/python && uv run src/main.py

##= Server Only (no web watch - use pre-built assets)

start-ts: build-web
	cd voice-agent/backend/typescript && pnpm run server

start-py: build-web
	cd voice-agent/backend/python && uv run src/main.py

##= Utilities

clean:
	rm -rf voice-agent/frontend/web/dist
	rm -rf voice-agent/frontend/web/node_modules
	rm -rf voice-agent/backend/typescript/node_modules
	rm -rf voice-agent/backend/python/.venv

# Type checking
check-web:
	cd voice-agent/frontend/web && pnpm check

check-ts:
	cd voice-agent/backend/typescript && pnpm run typecheck

check: check-web check-ts