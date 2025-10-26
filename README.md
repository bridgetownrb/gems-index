# Bridgetown Gems Server

This repo contains the source code for the canonical site located at https://gems.bridgetownrb.com.

## Install

> [!NOTE]
> When you clone this repo, you should have gems already built and available in the various `pkg` folders within the gem folders listed in `src/_data/load_gems.yml.

```sh
cd gems-index
bundle install && npm install
```

### Commands

```sh
# running locally
bin/bridgetown start

# build & deploy to production
bin/bridgetown deploy

# load the site up within a Ruby console (IRB)
bin/bridgetown console
```

> Learn more: [Bridgetown CLI Documentation](https://www.bridgetownrb.com/docs/command-line-usage)

## Contributing

If repo is on GitHub:

1. Fork it
2. Clone the fork using `git clone` to your local development machine.
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
