# Data Transformation and Star Schema Implementation using dbt

## Project Overview

This project focuses on data transformation and the implementation of a star schema using dbt (data build tool). The primary objective is to design and execute an efficient ETL (Extract, Transform, Load) data pipeline that converts raw source data into a structured star schema format. By leveraging dbt's capabilities, the project aims to streamline the process of building dimension and fact tables, facilitating analytical querying and reporting.

## Source Data

The source data contains the following columns:
- ProductID
- Date
- CustomerID
- CampaignID
- Units
- Product
- Category
- Segment
- ManufacturerID
- Manufacturer
- Unit Cost
- Unit Price
- ZipCode
- Email Name
- City
- State
- Region
- District
- Country
- LoadDate

## Target Schema

### Fact Table

The fact table will store transactional data and metrics for analysis. It will include the following fields:
- FactSales
  - SalesID
  - ProductSK
  - OrderDate
  - CustomerSK
  - CampaignSK
  - ManufacturerSK
  - Units
  - UpdatedTS

### Dimension Tables

The dimension tables will provide context to the fact table by storing descriptive information about the entities involved.

#### DimCustomer
- CustomerSK (surrogate key)
- CustomerID
- Email Name
- City
- State
- Region
- District
- Country
- UpdatedTS

#### DimDate
- OrderDate
- Day
- Month
- Quarter
- Year
- Weekday

#### DimProduct
- ProductSK (surrogate key)
- ProductID
- Product
- Category
- Segment
- UnitPrice
- UnitCost
- UpdatedTS

#### DimManufacturer
- ManufacturerSK (surrogate key)
- ManufacturerID
- Manufacturer
- UpdatedTS

#### DimGeo
- GeoSK (surrogate key)
- ZipCode
- City
- State
- Region
- District
- Country
- UpdatedTS

## Project Structure

The project is organized into the following directories and files:


### Models

- `models/sources/`: Contains source models that directly reference raw source data and perform initial transformations.
- `models/staging/`: Contains staging models that further clean and prepare the data from the source models.
- `models/marts/`: Contains the final transformed models representing the dimensional and fact tables in the star schema. These models are derived from the staging models and are optimized for analytical querying and reporting.

### Snapshots

- Directory for storing dbt snapshot definitions.

### Tests

- Directory for storing tests to validate the data models.

### Analyses

- Directory for storing analysis SQL files.

### Macros

- Directory for storing reusable SQL macros.

### Data

- Directory for storing additional data files.

### Seeds

- Directory for storing seed data files.

### dbt_project.yml

- The configuration file for the dbt project.

## How to Run the Project

1. **Install dbt**: Follow the official dbt installation guide [here](https://docs.getdbt.com/docs/installation).

2. **Set Up Profiles**: Configure your `profiles.yml` file to connect to your data warehouse.

3. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd <repository_name>
   
## How to Run the Project

Run the following dbt commands:

- To compile the models: `dbt compile`
- To run the models: `dbt run`
- To test the models: `dbt test`
- To generate documentation: `dbt docs generate`
- To serve the documentation: `dbt docs serve`

## Contributing

Since this is a private repository, contributions will mainly be made by the repository owner or authorized collaborators.

## Contact

For any questions or issues, please contact the repository owner at **NithinNizar@outlook.com**.
