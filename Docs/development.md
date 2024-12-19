# Development

## Build and deploy locally

```bash
docker compose build
docker compose up --detach app
docker compose run migrate
```

## Rebuild and redeploy

```bash
docker compose down
docker compose build
docker compose up --detach app
```

## Git

```bash
git checkout -b feature/<branch_name>
git checkout prime
git merge --squash feature/<branch_name>
git commit -m "Feature: [Description]"
```