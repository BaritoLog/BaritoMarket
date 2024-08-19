dev:
	@docker compose up --build
lint:
	@docker compose exec barito-market-ui npm run lint
build:
	@docker compose exec barito-market-ui npm run build
containerize:
	@docker build -t barito-market-ui:local --target=final-image .
