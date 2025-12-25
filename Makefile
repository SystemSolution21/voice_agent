.PHONY: bootstrap install-web install-ts install-py build-web dev-web start-ts start-py dev-ts dev-py clean

##= Installation

bootstrap: install-web install-ts install-py

install-web:
	cd voice-assistant-agent/web && pnpm install

install-ts:
	cd voice-assistant-agent/frontend && pnpm install

install-py:
	cd voice-assistant-agent/backend && uv sync --dev

##= Web Build

build-web:
	cd voice-assistant-agent/web && pnpm build

# Watch mode for web - rebuilds on changes
dev-web:
	cd voice-assistant-agent/web && pnpm build --watch

##= Development (web watch + server)

# frontend server with web watch
dev-ts:
	@echo "Starting web build watcher and frontend server..."
	@trap 'kill 0' EXIT; \
		(cd voice-assistant-agent/web && pnpm build --watch) & \
		sleep 2 && cd voice-assistant-agent/frontend && pnpm run server

# backend server with web watch
dev-py:
	@echo "Starting web build watcher and backend server..."
	@trap 'kill 0' EXIT; \
		(cd voice-assistant-agent/web && pnpm build --watch) & \
		sleep 2 && cd voice-assistant-agent/backend && uv run src/main.py

##= Server Only (no web watch - use pre-built assets)

start-ts: build-web
	cd voice-assistant-agent/frontend && pnpm run server

start-py: build-web
	cd voice-assistant-agent/backend && uv run src/main.py

##= Utilities

clean:
	rm -rf voice-assistant-agent/web/dist
	rm -rf voice-assistant-agent/web/node_modules
	rm -rf voice-assistant-agent/frontend/node_modules
	rm -rf voice-assistant-agent/backend/.venv

# Type checking
check-web:
	cd voice-assistant-agent/web && pnpm check

check-ts:
	cd voice-assistant-agent/frontend && pnpm run typecheck

check: check-web check-ts