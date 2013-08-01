# FCO Services

This app contains transaction start and done pages for the FCO payment transactions. These wrap around the existing Barclaycard EPDQ service.

## Routing

This application uses subdomain based routing to route to the individual transactions.  The start page for the transactions can be found at `<anything>.<slug>.*/start` (e.g. on a dev vm, they're at `www.<slug>.service.dev.gov.uk/start`).  The available slugs can be found in `lib/transactions.yml`.
