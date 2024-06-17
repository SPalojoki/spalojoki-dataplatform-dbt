# SPalojoki Dataplatform DBT

This repository contains the DBT project including most notably the **transformations** in the bigger ELT process of SPalojoki Dataplatform.

The extract and load processes are defined in a separate [spalojoki-dataplatform-importer](https://github.com/SPalojoki/spalojoki-dataplatform-importer) repository.

## Development

This DBT project is based on the *local* DBT-core and dbt-bigquery adapter.

### Setting the local environment up for the first time

1. Create a Python venv for the dbt project in a desired location and activate it.

    ```
    python -m venv dbt-env
    source dbt-env/bin/activate
    ```

    Make sure in .gitignore that the venv directory doesn't get pushed to the repository if stored in the project root.

2. Install dbt-core an dbt-bigquery adapter

    ```
    python -m pip install dbt-bigquery
    ```

3. Create a following `profiles.yml` file into `/home/spalojoki/.dbt` directory and append the missing values:

    ```
    spalojoki_dataplatform:
        target: dev
        outputs:
            dev:
                type: bigquery
                method: oauth
                project: GCP_PROJECT_ID
                dataset: {{initials}}__analytics # Must match the personal dev dataset
                threads: 4 
    ```

    The config used above uses Google Cloud CLI for the authentication. If willing to use other authentication method or cannot install `gcloud`, refer dbt docs [here](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup).


4. Check the configuration using `dbt debug`. If everything is okay, you are good to go!