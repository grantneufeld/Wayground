# Additional Tools to Install

These are only needed on development/testing environments — not production.

## Tidy

The html_validation gem requires the `tidy` command-line tool.

Using Homebrew on Mac, it can be installed with:
`brew install tidy-html5`

Make sure that the right tidy tool has priority in the shell `$PATH`.
Mac OS comes with an old (inadequate) version in `/usr/bin/tidy`.
Homebrew typically installs in `/user/local/bin/tidy`.
You can check which one is being used with the command `which tidy`.
