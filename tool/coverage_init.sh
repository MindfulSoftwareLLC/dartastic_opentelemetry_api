#!/bin/bash
#Initialized coverage
brew install lcov
dart pub global activate coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --package=. --report-on=lib
mkdir ./coverage
