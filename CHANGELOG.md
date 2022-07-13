# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.2]

### Added

* Started a changelog (which CI checks for)

## [0.2.1]

### Changed

* Separated out the corral-dependent example into examples_using_corral/
* Integrated with lib docs CI (see https://github.com/ponylang/library-documentation-action) and published API docs

## [0.2.0]

### Added

* Defines a set of frame/grid/rectangle/line drawing APIs and implements some line styles.
* Adds new `exmples/drawing` to test the new APIs

## [0.1.5]

### Added

* Add colour reset codes and color text formatting helpers.
* Add `examples/colors` with very basic text colour formatting

## [0.1.4]

### Fixed

* Fixes mouse enable/disable escape codes, works in `alacritty` now.

## [0.1.3]

### Changed

* Mousing example prints message before closing
* `Terminal` uses `Key` codes for ^C and ^Z

## [0.1.2]

### Added

* The example `using_corral` can be used to test using `termax` as a dependency via corral.

