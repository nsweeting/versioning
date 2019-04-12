# Versioning Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.0] - 2019-04-11

### Added
- `Versioning.Controller` which sets up support for usage with Phoenix controllers.
- `Versioning.Plug` which sets up a Plug.Conn to support versioning.
- `Versioning.View` which sets up support for usage with Phoenix views.
- `Versioning.update_data/3` added for easier dynamic versioning data updates.

### Changed
- Schema reflection on the latest version requires passing the type of the version
requested - either `:string` or `:parsed`
- The latest version on a schema can be modified with the `@latest` attribute.
- `Versioning.ExectionError` - raised when running a versioning through a schema -
was replaced with `VersioningError`.
- The tuple that represents a version within a schema now includes the string version.

## [0.1.1] - 2018-11-11

### Added
- `Versioning.Changelog` which documents a changelog for a `Versioning.Schema`.
- `Versioning.Changelog.Formatter` behaviour which allows a bare changelog map to be formatted in custom ways.
- `Versioning.Changelog.Markdown` formatter that turns a changelog into a markdown string.
- A module adhering to the `Versioning.Change` behaviour can now add the `@desc` attribute which the changelog will use.