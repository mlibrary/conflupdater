# Taghosts to Confluence

Given the source data for taghosts, update the relevant page in the Confluence wiki.

## Installation

Requires bundler to run the binstub

```bash
git clone https://github.com/mlibrary/conflupdater.git

cd  conflupdater

bundle install
```

Edit ```config/taghosts.sample.yml``` and rename to ```config/taghosts.yml```

## Use

```bash
bin/conflupdater help

bin/conflupdater print

bin/conflupdater taghosts path/to/active-servers
```

