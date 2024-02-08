# Meltano Tutorial

This repo is created through following the [official guide](https://docs.meltano.com/getting-started/part1) from Meltano's website.

The exercise was first perform on local machine with Meltano installed in Python virtual environment.

TODO: future exercise will include running Meltano in a docker container.

## Tutorial Summary

- Tutorial 1: This part initiates a new Meltano project and adding a tap to extract data from github using tap-github. Data extracted from github is saved as a `jsonl` output on local machine.
- Tutorial 2: This part builds on part 1 and loads the extracted data to a containerized PostgreSQL database.