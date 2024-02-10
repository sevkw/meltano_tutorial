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

Then try to re-do the Tutorial 1 through Tutorial 3 with docker

# Tutorial 1 Commands

Ensure you are in the `meltano-project-docker` directory to run the following commands. If not, you will have to updated the mounted volume's path to get docker running.

Alternatively, you can use an interactive Bash session to interact with docker. Simply run:

```bash
    docker run -v "$(pwd)":/meltano_learn -w /meltano_learn -it --entrypoint /bin/bash meltano/meltano
```

You should be able to run `meltano --version` successfully in the cli. To exit the container's shell, simply type `exit`.

### Adding tap-github

```bash
   docker run -v "$(pwd)":/meltano_learn -w /meltano_learn meltano/meltano add extractor tap-github --variant=meltanolabs
```

Continue following the tutorial using container's interactive shell.

# Tutorial 2 Postgres and Docker

Tutorial 3 involves loading the extracted data to a psql database hosted in a docker container. 
The challenge we have here is that we are running meltano in a different docker container. (Note that, if you do not run meltano in the interactive shell mode, you simply run each meltano command with a new container created. You can open up your Docker application to see how many containers you have created and exited.)

When you try to execute `meltano run tap-github target-postgres` it would fail, because meltano from container A could not find the postgres database from container B (Note: you can continue using the same meltano_postgres container you created when doing the tutorial on your local machine, or you can create a new container.)

This can be resolved by creating a docker network:

```bash
docker network create meltano_db
```

We have now created a docker network named `meltano_db` and now we want to connect it first to the `meltano_postgres` container we have created and running by running: (you can start the container first by running `docker start meltano_postgres`)
OR when creating the container, simply do:

```bash
docker run --name meltano_postgres2 -p 5432:5432 -e POSTGRES_USER=meltano -e POSTGRES_PASSWORD=password -d postgres --network meltano_db
```

```bash
docker network connect meltano_db meltano_postgres
```

Once the network is created and is connected to the `meltano_postgres` container. We need to get the correct host address when configure our `target-postgres` tap. Simply do the following:

run `docker inspect meltano_db`, the info of the `meltano_db` network will be returned. Now pay attention to the section:

```
"Containers": {
            "ed377adcc2cbf3692b6fa7c254898e5b75f9a9c718c8f7354136fd0a4a5980e1": {
                "Name": "meltano_postgres2",
                "EndpointID": "8d983d8791be7c16967622a80e760832917913a49d8391fc63b9d367a20bdf71",
                "MacAddress": "02:42:ac:14:00:02",
                "IPv4Address": "172.20.0.2/16",
                "IPv6Address": ""
            }
}
```

The IPv4Address value `172.20.0.2` is the value I grabbed for configuring the postgres host. **Note that yours might be a different number!**

Now open up `meltano.yml` on your local machine, and replace the `host: localhost` configuration under `target-postgres` section to the IP Value you just grabbed. Then run an interactive meltano conatiner:

Be careful, when you run the meltano container you need to do:


```bash
docker run -v "$(pwd)":/meltano_learn -w /meltano_learn -it --network meltano_db --entrypoint /bin/bash meltano/meltano 
```

inside the container, run 

```bash
meltano run tap-github target-postgres
```

You should see `Block run completed` message after this.

### Connecting SQL Editor to PostgreSQL
However, when connecting your SQL Editor to the database, you do not neet to update the host to `172.20.0.2`. You should still keep it as `localhost`.

You should be able to continue to Tutorial 3 and finish it.

# Tutorial 3 dbt-posgtres configuration

After initializing dbt-postgres pugin, remember to also configure host properly:

```bash
meltano config dbt-postgres set host 172.20.0.2
```

# Troubleshooting

## Docker Container File Permission

I ran the Tutorial on my own laptop directly on a Linux kernel (Ubuntu) and I ran into a FileSystem Error when mounting a volume to a docker container.
After running a few meltano commands through the container, the mounted volume would have new files added to the mounted project directory. However, when trying to read and write to the new files created, I received Permission Denied error.
I did some research on this issue, and it appears to be something specific to running docker container using a Linux kernel. Please check the Reference section with more details (there is a detailed explanation I found).

When inspecting the uid of owner on my local machine (simple ran `id` command), I had:

```
uid=1000(my_username)
```
When inspecting the uid of the container, I got:

```
uid=0(root)
```

The difference in the uid above shows that when running meltano to initiate a new project or configuring a plugin (thus changing the `meltano.yml` file), all the files that got added or updated through the container would have a uid of 0. Therefore, when exiting out of the container, we are back to our local machine, which has a different uid (for me it was 1000).
This issue could simply got resolved by running the following command, on local machine:

```bash
sudo chown -R 1000 </directory_of_project>
```

# Useful References for Learning Purpose

- docker run (with volume mounts) command [reference](https://docs.docker.com/engine/reference/commandline/container_run/#volume)
- docker mounted volume permission issue [explained here](https://github.com/docker/compose/issues/5507#issuecomment-353890002)