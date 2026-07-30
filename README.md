# VKS LDES vendor environment

A hosted instance of the [VKS design service](https://github.com/lblod/vks-design-service/),
taking data from the relevant LDES feed and making it available to vendors for integrating into their software.

## API documentation

### Vendor authentication

Access to this service is controlled by an API key per vendor.
A login request with a valid key provides a cookie which can be used for further requests.
The ['ar-design' plugin](https://github.com/lblod/frontend-embeddable-notule-editor/blob/master/docs/plugins/ar-design-plugin.md)
of the @lblod/embeddable-say-editor expects data in the same form as the `/ar-design` endpoint provides.

#### POST /login

The `/login` endpoint expects a `POST` whose body is a JSON of the form:

```json
{
  "organization": "http://data.lblod.info/id/bestuurseenheden/uri-of-bestuurseenheid",
  "publisher": {
    "uri": "http://data.lblod.info/foaf/agent/id/agent-uri",
    "key": "secret-api-key"
  }
}
```

#### GET /ar-designs

This lists the AR designs for the administrative unit (bestuurseenheid) that the cookie sent with the request corresponds to.

## Development

For development, the `docker-compose.dev.yml` provides development-only migrations.
Due to a problem with the VKS TEI LDES feed, these should not be run immediately, so this line of the compose config should be commented out when running from a fresh DB.

### Test users

The dev migrations create an agent with the API key "test", linked to the unit "Aalst".
The following JSON can be used to log in:

```json
{
  "organization": "http://data.lblod.info/id/bestuurseenheden/974816591f269bb7d74aa1720922651529f3d3b2a787f5c60b73e5a0384950a4",
  "publisher": {
    "uri": "http://data.lblod.info/foaf/agent/id/d44c7ea0-dc5f-43b2-ad10-e281a8aa646c",
    "key": "test"
  }
}
```

Further users can be created by copying and customising the migration used to create this user.
Keys must be hashed using the Argon2id algorithm.

### LDES infinite loop

The dev migration will fix the loop in the LDES feed, but only when the faulty page(s) have been reached.
The following query can be used to detect this:

```sparql
PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
SELECT ?state WHERE {
  GRAPH <http://mu.semte.ch/graphs/awv/ldes/status> {
    ?sub ext:LDESState ?state .
  }
}
```

If the JSON object that is returned has a `currentPage` field of
`https://services.apps-tei.mow.vlaanderen.be/ldes-server/geplande-opstellingen-v1/by-page?pageNumber=01858b83-86a8-466e-9f90-7c969b20ec31`
or
`https://services.apps-tei.mow.vlaanderen.be/ldes-server/geplande-opstellingen-v1/by-page?pageNumber=171beb63-a850-45e4-afcd-6cecbe3d90ca`,
then the correct pages have been reached.

Once this is the case, follow these steps:

- Stop the ldes client: `docker compose stop ldes-client`
- Uncomment the previously commented volume config from docker-compose.dev.yml
- 'Up' the migrations service to run the dev migrations: `docker compose up migrations`
- Once the migration has run (which can be verified with the above query), start the ldes-client: `docker compose up ldes-client`
- The syncing should then continue as normal

There are similar migrations for the dev feed.
The relevant stopping points can be found by looking at the `fix-dev-ldes-infinite-loop` migrations.
At the first stopping point, enable the dev-migrations and at the second, copy the second migration from config/additional-dev-migrations.
