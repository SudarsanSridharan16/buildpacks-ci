#!/bin/bash -l

set -ex

pushd binary-builder
  gem install bundler --no-ri --no-rdoc
  bundle config mirror.https://rubygems.org ${RUBYGEM_MIRROR}
  bundle install -j4

  if [ ${RUN_ORACLE_PHP_TESTS-false} = "true" ]; then
    apt-get update && apt-get -y install awscli
    bundle exec rspec spec/integration/${SPEC_TO_RUN}_spec.rb
  else
    bundle exec rspec spec/integration/${SPEC_TO_RUN}_spec.rb --tag ~run_oracle_php_tests
  fi
popd
