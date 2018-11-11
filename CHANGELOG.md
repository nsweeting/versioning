# Versioning Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.1.1] - 2018-11-11

### Added
- `Versioning.Changelog` which documents a changelog for a `Versioning.Schema`.
- `Versioning.Changelog.Formatter` behaviour which allows a bare changelog map to be formatted in custom ways.
- `Versioning.Changelog.Markdown` formatter that turns a changelog into a markdown string.
- A module adhering to the `Versioning.Change` behaviour can now add the `@desc` attribute which the changelog will use.