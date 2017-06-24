# Testing the code

These are instructions for testing the code, and guidelines for writing tests.


## Unit Testing With Rspec

To run the unit tests:
    > bundle exec rspec

### Autotest

While working on the code, you can have autotest continuously running in a terminal
to alert you when a change you make causes a test to fail.
It is configured to run the rspec test suite.

    > bundle exec autotest

While autotest is running, you can get it to rerun the entire set of specs by pressing control-c.

To quit autotest, you will need to press control-c twice in a row.


## Metrics

### Code Coverage

[SimpleCov](https://github.com/colszowka/simplecov) provides code coverage analysis
when used in conjunction with the testing suites.

In the current setup, the coverage reports are automatically updated when the test suites are run.
See `reports/coverage/index.html` for the report.

Note that the coverage report will be inaccurate if your most recent test run was only a partial run
(such as when autotest runs only the most recently edited spec file).

### Code Quality and Security Testing

The following gems do code analysis and metrics.
They are all called from the `preflight` shell script in the project root.
If you want to run them individually, you can copy the commands from the preflight script.

    > ./preflight

* [Brakeman](http://brakemanscanner.org/): Detects possible security risks.
* [bundler-audit](https://github.com/postmodern/bundler-audit): Detects some gems that are known to have security issues.
* [Rails Best Practices](https://github.com/railsbp/rails_best_practices): Identifies code that is considered to violate “best practices” for Rails programming.
* [Rubocop](https://github.com/bbatsov/rubocop): Identifies a wide variety of problematic code patterns, as well as enforcing style guidelines.
* [Ruby Critic](https://github.com/whitesmith/rubycritic): Identifies code smells, churn, and complexity.
