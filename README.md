# Meltano Tutorial

This repo is created through following the [official guide](https://docs.meltano.com/getting-started/part1) from Meltano's website.

The exercise was first perform on local machine with Meltano installed in Python virtual environment.

The project directory for running the Meltano project on a local machine (install meltano in virtual env) is in `my-meltano-project`.

TODO: future exercise will include running Meltano in a docker container.


## Tutorial Summary

- Tutorial 1: This part initiates a new Meltano project and adding a tap to extract data from github using tap-github. Data extracted from github is saved as a `jsonl` output on local machine.
- Tutorial 2: This part builds on part 1 and loads the extracted data to a containerized PostgreSQL database.
- Tutorial 3: This part builds on part 2 and transforms data using the dbt-postgres plugin

### Bug in Tutorial 3

There is a [post](https://github.com/meltano/meltano/issues/8391) detailing the bug when doing a `dbt run` command on `dbt-postgres`. I posted a solution and it worked out for me. 

**The following contents are not part of the tutorial:**

# Running Meltano in Docker Container

Use `meltano-project-docker` directory to initialize a new meltano project (running in docker container).

## Initialize New Project through Docker

After ensuring you have pulled the meltano/meltano image following this [guide here](https://docs.meltano.com/guide/installation-guide#using-pre-built-docker-images), make sure you are in the root directory of this repo. That is you need to cd to `meltano_learn`.

Then run the following command in terminal:

```bash
    docker run -v "$(pwd)":/meltano_learn -w /meltano_learn meltano/meltano init meltano-project-docker
```
After running you should see a new directory called `meltano-project-docker` being created.

### File Permission Check
After initializing the meltano project, if you try open up the meltano.yml file, you may encounter a Permission Error.
This can be resolved by:

1. cd into the new meltano project. For me, I ran `cd meltano-project-docker`
2. run `sudo chmod -R 755` which will give permission to allow you to edit file in VS Code


Then try to re-do the Tutorial 1 through Tutorial 3 with docker

# Tutorial 1 Commands

1. Adding tap-github

```bash
    docker run -v "$(pwd)":/meltano_learn -w /meltano_learn meltano/meltano add extractor tap-github --variant=meltanolabs
```

# Useful References for Learning Purpose

- docker run (with volume mounts) command [reference](https://docs.docker.com/engine/reference/commandline/container_run/#volume)
