# Taghosts to Confluence

Given the source data for taghosts, update the relevant page in the Confluence wiki.

## Use

```bash
CONFLUENCE_URL="https://example.com/confluence/rest/api"

# writes update.json file
ruby taghosts2confluence.rb

# posts update.json to confluence rest api
curl -u username:password -X PUT -H 'Content-Type: application/json' -d @update.json ${CONFLUENCE_URL}"/content/6095488" | python -mjson.tool
```

