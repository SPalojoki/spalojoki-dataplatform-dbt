# SPalojoki Data Platform dbt

This repository contains the dbt project responsible for the **transformations** in the larger ELT process of the SPalojoki Data Platform.

The extract and load processes, along with the daily production builds, are orchestrated in a separate [spalojoki-dataplatform-composer](https://github.com/SPalojoki/spalojoki-dataplatform-composer) repository containing Airflow DAGs.

## Data Architecture and Modeling

SPalojoki Data Platform follows the [medallion architecture introduced by Databricks](https://www.databricks.com/glossary/medallion-architecture).

### Medallion Architecture

Medallion architecture transforms data through three distinct layers: bronze, silver, and gold.

1. **Bronze Layer**
    - **Description:** The landing dataset for all data from external source systems.
    - **Structure:** Mirrors the source system tables "as-is" with additional metadata columns (e.g., load date/time).
    - **Purpose:** Maintains a historical archive of source data, enabling data lineage, auditability, and reprocessing without rereading the source data.

2. **Silver Layer**
    - **Description:** Processes data from the Bronze layer by matching, merging, and cleaning.
    - **Structure:** Uses 3rd Normal Form (3NF) or similar structures to maximize reusability.
    - **Purpose:** Ensures data consistency and quality.

3. **Gold Layer**
    - **Description:** Contains consumption-ready, project-specific datasets.
    - **Structure:** Uses de-normalized, read-optimized data models with fewer joins.
    - **Purpose:** Final data transformations, aggregations, and data quality checks for analytics, etc..

#### Further Reading
- [Databricks on Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- [Medallion Architecture: What, Why and How](https://medium.com/@junshan0/medallion-architecture-what-why-and-how-ce07421ef06f)

### Datasets and Tables

BigQuery uses a three-level structure for organizing data:
1. Google Cloud Project
2. Datasets
3. Tables

SPalojoki Data Platform organizes all data assets across environments (production, development) under one Google Cloud Project for simplicity. Development datasets are differentiated from production by adding developer initials to the dataset name.

```
{developer_initials}__dataset_name
```

Tables are divided into different datasets based on their refinement level, following the Medallion Architecture. There are five dataset types:

#### `Landing`

The Landing dataset stores data from source systems "as-is," representing the bronze layer in the Medallion Architecture. Each source can have one or more tables within this dataset. The tables in the Landing dataset are configured in dbt as source tables, thereby acting as the single source of truth across both development and production environments.

#### `Staging`

The Staging dataset contains dbt models that pull data from the Landing dataset into the dbt project. Essentially, it serves as a close duplicate of the Landing tables but within the dbt project, and can also be considered part of the bronze layer in the Medallion Architecture.

#### `Refined`

The Refined dataset represents the silver layer. This dataset contains models that structure data in 3rd Normal Form (3NF) or 3NF-like models. These models are designed to ensure data consistency and quality, making the data more reusable for downstream processing.

#### `Publish`

The Publish dataset corresponds to the gold layer and contains aggregated, use-case specific models. These models are de-normalized and read-optimized, designed to meet the needs of specific reporting and data consumption use cases.

#### `Intermediate`

The Intermediate dataset includes transformations that occur between the staging, refined, and publish datasets. These models are used to improve code clarity and manage complex transformations that don't fit neatly into the other categories.

Datasets are differentiated by appending a type suffix to the dataset name:

```
dataset_name__{dataset_type}
```

The dataset name is `analytics`. Consequently, the combined naming convention is:

```
{developer_initials}__analytics__{dataset_type}
```

## Using dbt

This dbt project uses a local dbt-core environment. Once your local environment is set up, you can develop, test, and run data transformations on development datasets before deploying them to production.

### Common dbt Commands

- `dbt build`: Compiles, runs, and tests your dbt models.
- `dbt run`: Executes your dbt models.
- `dbt test`: Runs tests on your dbt models.
- `dbt seed`: Loads CSV files from the `seeds` directory into the database.
- `dbt compile`: Compiles your dbt models into SQL queries.

For more detailed documentation, refer to the [dbt commands reference](https://docs.getdbt.com/reference/dbt-commands).

#### Selecting Specific Models

Use the `--select` option to specify which models to `build`, `run`, or `test`. The `+` symbol includes upstream and downstream dependencies.

*Example: Run a specific model and its upstream dependencies:*

```sh
dbt run --select +my_model
```

### High-level Development Workflow

1. **Add or Modify SQL Files in the Models Directory**
    - Define your data transformations by adding or modifying SQL files in the `models` directory.
    - Use `dbt run` to test and iterate on these models.
    - Inspect results in your development datasets on Google Cloud Console or the dbt query result inspector.

2. **Add/Update Documentation and Tests**
    - Add model and column definitions, as well as tests, to the `.yml` files for `refined` and `publish` models.
    - Validate tests by running `dbt test` or `dbt build`.

3. **Commit Changes to Version Control**
    - Changes committed to the main branch are reflected in the production datasets.
    - These changes take effect after the next production `dbt run` (either at UTC midnight or after the next data ingestion job).
    - To apply changes immediately to production, manually trigger the `daily dbt build` DAG in Airflow.

## Setting Up the Local Environment

### Prerequisites

- Python
- Google Cloud CLI

### Steps

1. **Create a Python Virtual Environment and Activate It**
    ```sh
    python -m venv dbt-env
    source dbt-env/bin/activate
    ```

    Ensure the venv directory is excluded in `.gitignore` if stored in the project root.

2. **Install necessary dependencies**
    ```sh
    pip install -r requirements.txt
    ```

3. **Configure `profiles.yml`**

    Create the following `profiles.yml` file in `/Users/{user}/.dbt` and fill in the missing values:
    ```yaml
    spalojoki_dataplatform:
        target: dev
        outputs:
            dev:
                type: bigquery
                method: oauth
                project: {{GCP_PROJECT_ID}}
                dataset: {{initials}}__analytics
                threads: 4
    ```

    Set up Google Cloud CLI authentication:
    ```sh
    gcloud auth application-default login
    ```

    For alternative authentication methods, refer to the [dbt documentation](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup).

4. **Check Configuration**
    Run `dbt debug` to verify the configuration.

5. **Setup the linting pre-commit hook**

    ```sh
    pre-commit install
    ```

6. **Optional: Install dbt Power User VS Code Plugin**
    For lineage and other features.

## Production Deployment

Daily production builds are orchestrated using Airflow, with the DAGs defined in the spalojoki-dataplatform-composer repository. The production environment `dbt profile` is stored in `prod_profile` directory of this repository.

The `main` branch serves as the source for production deployment. Changes merged into main are automatically applied during the next daily dbt build or after the subsequent data ingestion job. If you need to apply changes immediately to production, you can manually trigger the `daily_dbt_build` DAG in Airflow.

For details on accessing and configuring Airflow, refer to the [spalojoki-infrastructure](https://github.com/SPalojoki/spalojoki-infrastructure) repository.
