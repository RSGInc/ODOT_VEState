#========================================================
#Define function to calculate county performance measures
#========================================================
calcCountyMeasures <- 
  function(Year, Az, DstoreLocs_ = c("Datastore"), DstoreType = "RD") {
    
    #Prepare for datastore queries
    #-----------------------------
    QPrep_ls <- prepareForDatastoreQuery(
      DstoreLocs_ = DstoreLocs_,
      DstoreType = DstoreType
    )
    
    #Define function to create a data frame of measures
    #--------------------------------------------------
    makeMeasureDataFrame <- function(DataNames_, Az) {
      if (length(Az) > 1) {
        Data_XAz <- t(sapply(DataNames_, function(x) get(x)))
      } else {
        Data_XAz <- t(t(sapply(DataNames_, function(x) get(x))))
      }
      colnames(Data_XAz) <- Az
      Measures_ <- gsub("_Az", "", DataNames_)
      Units_ <- 
        unname(sapply(DataNames_, function(x) attributes(get(x))$Units))
      Description_ <- 
        unname(sapply(DataNames_, function(x) attributes(get(x))$Description))
      Data_df <- cbind(
        Measure = Measures_,
        data.frame(Data_XAz),
        Units = Units_,
        Description = Description_
      )
      rownames(Data_df) <- NULL
      Data_df
    }
    
    #=========================    
    #HOUSEHOLD CHARACTERISTICS
    #=========================
    
    #Number of households in Marea
    #-----------------------------
    Households <- summarizeDatasets(
      Expr = "count(HhSize)",
      Units_ = c(
        HhSize = "",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(Households) <- 
      list(Units = "Households",
           Description = "Number of households residing in Azone")
    
    #Population
    #----------
    Population <- summarizeDatasets(
      Expr = "sum(HhSize)",
      Units_ = c(
        HhSize = "PRSN",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(Population) <- list(
      Units = "persons",
      Description = "Total population"
    )
    
    #Population in urban households
    #------------------------------
    PopulationUrban <- summarizeDatasets(
      Expr = "sum(HhSize[LocType == 'Urban'])",
      Units_ = c(
        HhSize = "PRSN",
        LocType = "category",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(PopulationUrban) <- list(
      Units = "person",
      Description = "Urban population"
    )
    
    #Population in town households
    #------------------------------
    PopulationTown <- summarizeDatasets(
      Expr = "sum(HhSize[LocType == 'Town'])",
      Units_ = c(
        HhSize = "PRSN",
        LocType = "category",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(PopulationTown) <- list(
      Units = "person",
      Description = "Town population"
    )
    
    #Population in rural households
    #------------------------------
    PopulationRural <- summarizeDatasets(
      Expr = "sum(HhSize[LocType=='Rural'])",
      Units_ = c(
        HhSize = "PRSN",
        LocType = "category",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(PopulationRural) <- list(
      Units = "person",
      Description = "Rural population"
    )
    
    #Data frame of household characteristics
    #---------------------------------------
    HhCharacteristics_df <- makeMeasureDataFrame(
      DataNames_ = c(
        "Households",
        "PopulationUrban",
        "PopulationTown",
        "PopulationRural"
      ),
      Az = Az
    )
    
    #====================   
    #Daily Miles Traveled
    #====================
    
    #Household DVMT
    #--------------
    HouseholdDvmt <- summarizeDatasets(
      Expr = "sum(Dvmt)",
      Units = c(
        Dvmt = "MI/DAY",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    ) [Az]
    attributes(HouseholdDvmt) <- list(
      Units = "miles per day",
      Description = "Total DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters"
    )
    
    #County household DVMT per capita
    #-----------------------------------
    HouseholdDvmtPerPrsn <- HouseholdDvmt / Population
    attributes(HouseholdDvmtPerPrsn ) <- list(
      Units = "Miles per day",
      Description = "Daily vehicle miles traveled per capita residing in the Azone"
    )
    
    #Transit trips
    #-------------
    TransitTrips <- summarizeDatasets(
      Expr = "sum(TransitTrips)",
      Units_ = c(
        TransitTrips = "TRIPS/YR",
        Azone = ""
        ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(TransitTrips) <- list(
      Units = "trips per year",
      Description = "Annual total household transit trips"
    )
    
    #Transit trips per capita
    #------------------------
    TransitTripsPerPrsn <- TransitTrips / Population
    attributes(TransitTripsPerPrsn) <- list(
      Units = "trips per year per capita",
      Description = "Annual transit trips per capita"
    )
    
    #Bike trips
    #----------
    BikeTrips <- summarizeDatasets(
      Expr = "sum(BikeTrips)",
      Units_ = c(
        BikeTrips = "TRIPS/YR",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(BikeTrips) <- list(
      Units = "trips per year",
      Description = "Annual total household bike trips"
    )
    
    #Bike trips per capita
    #---------------------
    BikeTripsPerPrsn <- BikeTrips / Population
    attributes(BikeTripsPerPrsn) <- list(
      Units = "trips per year per capita",
      Description = "Annual bike trips per capita"
    )
    
    #Walk trips
    #----------
    WalkTrips <- summarizeDatasets(
      Expr = "sum(WalkTrips)",
      Units_ = c(
        WalkTrips = "TRIPS/YR",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(WalkTrips) <- list(
      Units = "trips per year",
      Description = "Annual total household walk trips"
    )
    
    #Walk trips per capita
    #---------------------
    WalkTripsPerPrsn <- WalkTrips / Population
    attributes(WalkTripsPerPrsn) <- list(
      Units = "trips per year per capita",
      Description = "Annual walk trips per capita"
    )
    
    #Number of household vehicles
    #----------------------------
    NumHouseholdVehicles <- summarizeDatasets(
      Expr = "sum(NumAuto) + sum(NumLtTrk)",
      Units_ =  c(
        NumAuto = "VEH",
        NumLtTrk = "VEH",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(NumHouseholdVehicles) <- list(
      Units = "vehicles",
      Description = "Number of vehicles owned or leased by households"
    )
    
    #Data frame of DVMT values
    #-------------------------
    Dvmt_df <- makeMeasureDataFrame(
      DataNames_ = c(
        "HouseholdDvmt",
        "HouseholdDvmtPerPrsn",
        "TransitTripsPerPrsn",
        "BikeTripsPerPrsn",
        "WalkTripsPerPrsn",
        "NumHouseholdVehicles"
      ),
      Az = Az
    )
    
    #======================
    #Vehicle Ownership Cost
    #======================
    
    #Ownership cost proportion
    #-------------------------
    OwnCostProp <- summarizeDatasets(
      Expr = "sum(OwnCost)/sum(Income)",
      Units_ = c(
        OwnCost = "USD",
        Income = "USD",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(OwnCostProp) <- list(
      Units = "proportion",
      Description = "Vehicle ownership cost as a proportion of household income"
    )
    
    #Ownership cost for households with less than 25K income
    #-------------------------------------------------------
    OwnCostPropHhLess25K <- summarizeDatasets(
      Expr = "sum(OwnCost[Income < 25000])/sum(Income[Income < 25000])",
      Units_ = c(
        OwnCost = "USD",
        Income = "USD",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(OwnCostPropHhLess25K) <- list(
      Units = "proportion",
      Description = "Vehicle ownerhsip cost as a proportion of household income for households earning less than 25K"
    )
    
    #Operating cost
    #--------------
    VehCostProp <- summarizeDatasets(
      Expr = "sum(AveVehCostPM * Dvmt)/sum(Income)",
      Units_ = c(
        AveVehCostPM = "USD",
        Dvmt = "MI/DAY",
        Income = "USD",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(VehCostProp) <- list(
      Units = "proportion",
      Description = "Vehicle operating cost as a proportion of household income"
    )
    
    #Operating cost for households with less than 25K income
    #-------------------------------------------------------
    VehCostPropHhLess25K <- summarizeDatasets(
      Expr = "sum(AveVehCostPM[Income < 25000] * Dvmt[Income < 25000])/sum(Income[Income < 25000])",
      Units_ = c(
        AveVehCostPM = "USD",
        Dvmt = "MI/DAY",
        Income = "USD",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(VehCostPropHhLess25K) <- list(
      Units = "proportion",
      Description = "Vehicle operating cost as a proportion of household income for households earning less than 25K"
    )
    
    #Operating cost for households with residents 65 and older
    #--------------------------------------------------------
    VehCostPropHhAge65Plus <- summarizeDatasets(
      Expr = "sum(AveVehCostPM[Age65Plus > 0] * Dvmt[Age65Plus > 0])/sum(Income[Age65Plus > 0])",
      Units_ = c(
        AveVehCostPM = "USD",
        Dvmt = "MI/DAY",
        Income = "USD",
        Age65Plus = "AGE",
        Azone = ""
      ),
      By_ = "Azone",
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )[Az]
    attributes(VehCostPropHhAge65Plus) <- list(
      Units = "proportion",
      Description = "Vehicle operating cost as a proportion of household income for households with residents age 65 and older"
    )
    
    #Data frame of cost values
    #-------------------------
    Cost_df <- makeMeasureDataFrame(
      DataNames_ = c(
        "OwnCostProp",
        "OwnCostPropHhLess25K",
        "VehCostProp",
        "VehCostPropHhLess25K",
        "VehCostPropHhAge65Plus"
      ),
      Az = Az
    )
    
    #Return data frame of all results
    #--------------------------
    rbind(
      HhCharacteristics_df,
      Dvmt_df,
      Cost_df
    )
  }
    