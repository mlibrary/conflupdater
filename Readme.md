# Confluence Updater

A command line utility to easy updating confluence from regular data sources.  Originally written to update the taghosts page and the IIA vulnerability scan reports.

## Installation

Requires bundler to run the binstub

```bash
git clone https://github.com/mlibrary/conflupdater.git

cd  conflupdater

bundle install

bin/setup
```

Edit `config/conflupdater.yml` and fill in appropriate values for the hostname and space key.

## Use

```bash
bin/conflupdater help

bin/conflupdater print

bin/conflupdater pages

bin/conflupdater find "Page Title"

bin/conflupdater taghosts path/to/active-hosts

bin/conflupdater vulnscan "Page Title" path/to/vuln-scan-content
```

