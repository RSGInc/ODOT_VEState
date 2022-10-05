
# AssignDrivers Module
### July 8, 2020

This module assigns drivers by age group to each household as a function of the numbers of persons and workers by age group, the household income, land use characteristics, and public transit availability. Users may specify the relative driver licensing rate relative to the model estimation data year in order to account for observed or projected changes in licensing rates.

## Model Parameter Estimation

Binary logit models are estimated to predict the probability that a person has a drivers license. Two versions of the model are estimated, one for persons in a metropolitan (i.e. urbanized) area, and another for persons located in non-metropolitan areas. There are different versions because the estimation data have more information about transportation system and land use characteristics for households located in urbanized areas. In both versions, the probability that a person has a drivers license is a function of the age group of the person, whether the person is a worker, the number of persons in the household, the income and squared income of the household, whether the household lives in a single-family dwelling, and the population density of the Bzone where the person lives. In the metropolitan area model, the bus-equivalent transit revenue miles and whether the household resides in an urban mixed-use neighborhood are significant factors. Following are the summary statistics for the metropolitan model:

```

Call:
glm(formula = makeFormula(StartTerms_), family = binomial, data = EstData_df[TrainIdx, 
    ])

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.3017   0.1300   0.2090   0.3954   3.0871  

Coefficients:
                  Estimate Std. Error z value Pr(>|z|)    
(Intercept)     -1.810e+01  1.053e+02  -0.172    0.864    
Age15to19        1.713e+01  1.053e+02   0.163    0.871    
Age20to29        1.957e+01  1.053e+02   0.186    0.853    
Age30to54        1.991e+01  1.053e+02   0.189    0.850    
Age55to64        1.974e+01  1.053e+02   0.188    0.851    
Age65Plus        1.913e+01  1.053e+02   0.182    0.856    
Worker           1.243e+00  5.111e-02  24.313   <2e-16 ***
HhSize          -2.723e-01  1.657e-02 -16.433   <2e-16 ***
Income           4.617e-05  1.986e-06  23.240   <2e-16 ***
IncomeSq        -1.941e-10  1.186e-11 -16.376   <2e-16 ***
IsSF             4.714e-01  5.082e-02   9.275   <2e-16 ***
PopDensity      -4.028e-05  3.171e-06 -12.702   <2e-16 ***
IsUrbanMixNbrhd -5.727e-01  5.969e-02  -9.595   <2e-16 ***
TranRevMiPC     -7.917e-03  7.480e-04 -10.584   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 26755  on 31394  degrees of freedom
Residual deviance: 14964  on 31381  degrees of freedom
  (10167 observations deleted due to missingness)
AIC: 14992

Number of Fisher Scoring iterations: 16

```

Following are the summary statistics for the non-metropolitan model:

```

Call:
glm(formula = makeFormula(StartTerms_), family = binomial, data = EstData_df[TrainIdx, 
    ])

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.2832   0.1236   0.1783   0.3497   2.5611  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept) -1.949e+01  1.152e+02  -0.169    0.866    
Age15to19    1.856e+01  1.152e+02   0.161    0.872    
Age20to29    2.085e+01  1.152e+02   0.181    0.856    
Age30to54    2.100e+01  1.152e+02   0.182    0.855    
Age55to64    2.103e+01  1.152e+02   0.183    0.855    
Age65Plus    2.036e+01  1.152e+02   0.177    0.860    
Worker       1.614e+00  4.584e-02  35.203   <2e-16 ***
HhSize      -2.219e-01  1.468e-02 -15.113   <2e-16 ***
Income       4.457e-05  1.802e-06  24.738   <2e-16 ***
IncomeSq    -2.060e-10  1.131e-11 -18.221   <2e-16 ***
IsSF         4.226e-01  4.302e-02   9.823   <2e-16 ***
PopDensity  -6.122e-05  3.680e-06 -16.635   <2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 43304  on 57782  degrees of freedom
Residual deviance: 21923  on 57771  degrees of freedom
  (16563 observations deleted due to missingness)
AIC: 21947

Number of Fisher Scoring iterations: 17

```

The models are estimated using the *Hh_df* (household) and *Per_df* (person) datasets in the VE2001NHTS package. Information about these datasets and how they were developed from the 2001 National Household Travel Survey public use dataset is included in that package.

## How the Module Works

The module iterates through each age group excluding the 0-14 year age group and creates a temporary set of person records for households in the region. For each household there are as many person records as there are persons in the age group in the household. A worker status attribute is added to each record based on the number of workers in the age group in the household. For example, if a household has 2 persons and 1 worker in the 20-29 year age group, one of the records would have its worker status attribute equal to 1 and the other would have its worker status attribute equal to 0. The person records are also populated with the household characteristics used in the model. The binomial logit model is applied to the person records to determine the probability that each person is a driver. The driver status of each person is determined by random draws with the modeled probability determining the likelihood that the person is determined to be a driver. The resulting number of drivers in the age group is then tabulated by household.


## User Inputs
The following table(s) document each input file that must be provided in order for the module to run correctly. User input files are comma-separated valued (csv) formatted text files. Each row in the table(s) describes a field (column) in the input file. The table names and their meanings are as follows:

NAME - The field (column) name in the input file. Note that if the 'TYPE' is 'currency' the field name must be followed by a period and the year that the currency is denominated in. For example if the NAME is 'HHIncomePC' (household per capita income) and the input values are in 2010 dollars, the field name in the file must be 'HHIncomePC.2010'. The framework uses the embedded date information to convert the currency into base year currency amounts. The user may also embed a magnitude indicator if inputs are in thousand, millions, etc. The VisionEval model system design and users guide should be consulted on how to do that.

TYPE - The data type. The framework uses the type to check units and inputs. The user can generally ignore this, but it is important to know whether the 'TYPE' is 'currency'

UNITS - The units that input values need to represent. Some data types have defined units that are represented as abbreviations or combinations of abbreviations. For example 'MI/HR' means miles per hour. Many of these abbreviations are self evident, but the VisionEval model system design and users guide should be consulted.

PROHIBIT - Values that are prohibited. Values may not meet any of the listed conditions.

ISELEMENTOF - Categorical values that are permitted. Value must be one of the listed values.

UNLIKELY - Values that are unlikely. Values that meet any of the listed conditions are permitted but a warning message will be given when the input data are processed.

DESCRIPTION - A description of the data.

### region_hh_ave_driver_per_capita.csv
This input file is OPTIONAL.

|NAME             |TYPE     |UNITS    |PROHIBIT     |ISELEMENTOF |UNLIKELY |DESCRIPTION                                                            |
|:----------------|:--------|:--------|:------------|:-----------|:--------|:----------------------------------------------------------------------|
|Year             |         |         |             |            |         |Must contain a record for each model run year                          |
|DrvPerPrsn15to19 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 15 to 19 years old age group |
|DrvPerPrsn20to29 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 20 to 29 years old age group |
|DrvPerPrsn30to54 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 30 to 54 years old age group |
|DrvPerPrsn55to64 |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 55 to 64 years old age group |
|DrvPerPrsn65Plus |compound |DRV/PRSN |NA, < 0, > 1 |            |         |Target ratio of drivers to persons in the 65 or older age group        |

## Datasets Used by the Module
The following table documents each dataset that is retrieved from the datastore and used by the module. Each row in the table describes a dataset. All the datasets must be present in the datastore. One or more of these datasets may be entered into the datastore from the user input files. The table names and their meanings are as follows:

NAME - The dataset name.

TABLE - The table in the datastore that the data is retrieved from.

GROUP - The group in the datastore where the table is located. Note that the datastore has a group named 'Global' and groups for every model run year. For example, if the model run years are 2010 and 2050, then the datastore will have a group named '2010' and a group named '2050'. If the value for 'GROUP' is 'Year', then the dataset will exist in each model run year group. If the value for 'GROUP' is 'BaseYear' then the dataset will only exist in the base year group (e.g. '2010'). If the value for 'GROUP' is 'Global' then the dataset will only exist in the 'Global' group.

TYPE - The data type. The framework uses the type to check units and inputs. Refer to the model system design and users guide for information on allowed types.

UNITS - The units that input values need to represent. Some data types have defined units that are represented as abbreviations or combinations of abbreviations. For example 'MI/HR' means miles per hour. Many of these abbreviations are self evident, but the VisionEval model system design and users guide should be consulted.

PROHIBIT - Values that are prohibited. Values in the datastore do not meet any of the listed conditions.

ISELEMENTOF - Categorical values that are permitted. Values in the datastore are one or more of the listed values.

|NAME             |TABLE     |GROUP |TYPE      |UNITS      |PROHIBIT     |ISELEMENTOF        |
|:----------------|:---------|:-----|:---------|:----------|:------------|:------------------|
|DrvPerPrsn15to19 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn20to29 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn30to54 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn55to64 |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|DrvPerPrsn65Plus |Region    |Year  |compound  |DRV/PRSN   |NA, < 0, > 1 |                   |
|Marea            |Marea     |Year  |character |ID         |             |                   |
|TranRevMiPC      |Marea     |Year  |compound  |MI/PRSN/YR |NA, < 0      |                   |
|Bzone            |Bzone     |Year  |character |ID         |             |                   |
|D1B              |Bzone     |Year  |compound  |PRSN/SQMI  |NA, < 0      |                   |
|Marea            |Household |Year  |character |ID         |             |                   |
|Bzone            |Household |Year  |character |ID         |             |                   |
|HhId             |Household |Year  |character |ID         |             |                   |
|Age15to19        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age20to29        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age30to54        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age55to64        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Age65Plus        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr15to19        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr20to29        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr30to54        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr55to64        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Wkr65Plus        |Household |Year  |people    |PRSN       |NA, < 0      |                   |
|Income           |Household |Year  |currency  |USD.2001   |NA, < 0      |                   |
|HhSize           |Household |Year  |people    |PRSN       |NA, <= 0     |                   |
|HouseType        |Household |Year  |character |category   |             |SF, MF, GQ         |
|IsUrbanMixNbrhd  |Household |Year  |integer   |binary     |NA           |0, 1               |
|LocType          |Household |Year  |character |category   |NA           |Urban, Town, Rural |

## Datasets Produced by the Module
The following table documents each dataset that is placed in the datastore by the module. Each row in the table describes a dataset. All the datasets must be present in the datastore. One or more of these datasets may be entered into the datastore from the user input files. The table names and their meanings are as follows:

NAME - The dataset name.

TABLE - The table in the datastore that the data is placed in.

GROUP - The group in the datastore where the table is located. Note that the datastore has a group named 'Global' and groups for every model run year. For example, if the model run years are 2010 and 2050, then the datastore will have a group named '2010' and a group named '2050'. If the value for 'GROUP' is 'Year', then the dataset will exist in each model run year. If the value for 'GROUP' is 'BaseYear' then the dataset will only exist in the base year group (e.g. '2010'). If the value for 'GROUP' is 'Global' then the dataset will only exist in the 'Global' group.

TYPE - The data type. The framework uses the type to check units and inputs. Refer to the model system design and users guide for information on allowed types.

UNITS - The native units that are created in the datastore. Some data types have defined units that are represented as abbreviations or combinations of abbreviations. For example 'MI/HR' means miles per hour. Many of these abbreviations are self evident, but the VisionEval model system design and users guide should be consulted.

PROHIBIT - Values that are prohibited. Values in the datastore do not meet any of the listed conditions.

ISELEMENTOF - Categorical values that are permitted. Values in the datastore are one or more of the listed values.

DESCRIPTION - A description of the data.

|NAME          |TABLE     |GROUP |TYPE   |UNITS |PROHIBIT |ISELEMENTOF |DESCRIPTION                                            |
|:-------------|:---------|:-----|:------|:-----|:--------|:-----------|:------------------------------------------------------|
|Drv15to19     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 15 to 19 years old                   |
|Drv20to29     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 20 to 29 years old                   |
|Drv30to54     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 30 to 54 years old                   |
|Drv55to64     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 55 to 64 years old                   |
|Drv65Plus     |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers 65 or older                          |
|Drivers       |Household |Year  |people |PRSN  |NA, < 0  |            |Number of drivers in household                         |
|DrvAgePersons |Household |Year  |people |PRSN  |NA, < 0  |            |Number of people 15 year old or older in the household |
