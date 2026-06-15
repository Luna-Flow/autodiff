set shell := ["bash", "-cu"]

default:
  @just --list

fmt:
  moon fmt

check:
  moon check

info:
  moon info

test:
  ./run_test.sh

ready:
  ./ready_to_pr.sh

clean:
  moon clean

coverage-clean:
  moon coverage clean
