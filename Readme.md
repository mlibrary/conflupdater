# Taghosts to Confluence

Given the source data for taghosts, update the relevant page in the Confluence wiki.

## Installation

Requires bundler to run the binstub

```bash
git clone https://github.com/mlibrary/conflupdater.git

cd  conflupdater

bundle install

bin/setup
```

Edit `config/conflupdater.yml` and fill in appropriate values.

## Use

```bash
bin/conflupdater help

bin/conflupdater print

bin/conflupdater pages

bin/conflupdater taghosts 
```

