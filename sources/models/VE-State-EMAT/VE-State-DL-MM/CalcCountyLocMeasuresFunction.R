#========================================================
#Define function to calculate county performance measures
#========================================================
calcCountyLocMeasures <- 
  function(Year, Az, DstoreLocs_ = c("Datastore"), DstoreType = "RD") {
    
    #Prepare for datastore queries
    #-----------------------------
    QPrep_ls <- prepareForDatastoreQuery(
      DstoreLocs_ = DstoreLocs_,
      DstoreType = DstoreType
    )
    
    #Get county-location-type combinations
    #-------------------------------------
    AzLoc <- c()
    for (a in Az) {
      az <- rep(a, 3)
      az[1] <- paste0(az[1],"_","Rural")
      az[2] <- paste0(az[2],"_","Town")
      az[3] <- paste0(az[3],"_","Urban")
      AzLoc <- c(AzLoc, az)
    }
    
    #Define function to create a data frame of measures
    #--------------------------------------------------
    makeMeasureDataFrame <- function(DataNames_, Az) {
      if (length(Az) > 1) {
        Data_XAzLoc <- t(sapply(DataNames_, function(x) get(x)))
      } else {
        Data_XAzLoc <- t(t(sapply(DataNames_, function(x) get(x))))
      }
      colnames(Data_XAzLoc) <- AzLoc
      Measures_ <- gsub("_AzLoc", "", DataNames_)
      Units_ <- 
        unname(sapply(DataNames_, function(x) attributes(get(x))$Units))
      Description_ <- 
        unname(sapply(DataNames_, function(x) attributes(get(x))$Description))
      Data_df <- cbind(
        Measure = Measures_,
        data.frame(Data_XAzLoc),
        Units = Units_,
        Description = Description_
      )
      rownames(Data_df) <- NULL
      Data_df
    }
    
    #=========================    
    #HOUSEHOLD CHARACTERISTICS
    #=========================
    
    #Population
    #----------
    Population <- summarizeDatasets(
      Expr = "sum(HhSize)",
      Units_ = c(
        HhSize = "PRSN",
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(Population) <- list(
      Units = "persons",
      Description = "Total population"
    )
    
    #Number of households
    #--------------------
    Households <- summarizeDatasets(
      Expr = "count(HhSize)",
      Units_ = c(
        HhSize = "",
        Azone = "",
        LocType = ""
        ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(Households) <- 
      list(Units = "Households",
           Description = "Number of households residing in Azone Location Type")
    
    #Data frame of household characteristics
    #---------------------------------------
    HhCharacteristics_df <- makeMeasureDataFrame(
      DataNames_ = c(
        "Population",
        "Households"
      ),
      Az = Az
    )
    
    #Return data frame of all results
    #--------------------------
    rbind(
      HhCharacteristics_df
    )
    
    #====================   
    #Daily Miles Traveled
    #====================
    
    #Household DVMT per capita
    #-------------------------
    HouseholdDvmtPerPrsn <- summarizeDatasets(
      Expr = "sum(Dvmt)/sum(HhSize)",
      Units = c(
        Dvmt = "MI/DAY",
        HhSize = "people",
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(HouseholdDvmtPerPrsn) <- list(
      Units = "miles per day",
      Description = "Total DVMT (in owned and car service vehicles) per capita in households and non-institutional group quarters"
    )
    
    #Household car service DVMT
    #--------------------------
    HouseholdCarSvcDvmt <- summarizeDatasets(
      Expr = "sum(Dvmt[VehicleAccess != 'Own'] * DvmtProp[VehicleAccess != 'Own'])",
      Units = c(
        Dvmt = "MI/DAY",
        DvmtProp = "",
        VehicleAccess = "",
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = list(
        Household = c("Dvmt", "LocType", "Azone"),
        Vehicle = c("DvmtProp", "VehicleAccess")
      ),
      Key = "HhId",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(HouseholdCarSvcDvmt) <- list(
      Units = "miles per day",
      Description = "Total DVMT in car service vehicles of persons in households and non-institutional group quarters"
    )
    
    #Household car service DVMT per capita
    #-------------------------------------
    HouseholdCarSvcDvmtPerPrsn <- HouseholdCarSvcDvmt/Population
    attributes(HouseholdCarSvcDvmtPerPrsn) <- list(
      Units = "miles per day",
      Description = "Per capita household DVMT in car service vehicles of persons in households and non-institutional group quarters"
    )
    
    #Transit PMT per capita
    #----------------------
    TransitPMTPerPrsn <- summarizeDatasets(
      Expr = "sum(TransitPMT)/sum(HhSize)",
      Units_ = c(
        TransitPMT = "MI/DAY",
        HhSize = "people",
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(TransitPMTPerPrsn) <- list(
      Units = "miles per day",
      Description = "Annual total household transit PMT per capita"
    )
    
    #Bike PMT per capita
    #-------------------
    BikePMTPerPrsn <- summarizeDatasets(
      Expr = "sum(BikePMT)/sum(HhSize)",
      Units_ = c(
        BikePMT = "MI/DAY",
        HhSize = "people",
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(BikePMTPerPrsn) <- list(
      Units = "miles per day",
      Description = "Annual total household bike PMT per capita"
    )
    
    #Walk PMT per capita
    #---------------------
    WalkPMTPerPrsn <- summarizeDatasets(
      Expr = "sum(WalkPMT)/sum(HhSize)",
      Units_ = c(
        WalkPMT = "MI/DAY",
        HhSize = "people",
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
    attributes(WalkPMTPerPrsn) <- list(
      Units = "miles per day",
      Description = "Annual total household walk PMT per capita"
    )
    
    
    #Data frame of DVMT values
    #-------------------------
    Dvmt_df <- makeMeasureDataFrame(
      DataNames_ = c(
        "HouseholdDvmtPerPrsn",
        "HouseholdCarSvcDvmt",
        "HouseholdCarSvcDvmtPerPrsn",
        "TransitPMTPerPrsn",
        "BikePMTPerPrsn",
        "WalkPMTPerPrsn"
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
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
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
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
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
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
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
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
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
        Azone = "",
        LocType = ""
      ),
      By_ = c("LocType", "Azone"),
      Table = "Household",
      Group = Year,
      QueryPrep_ls = QPrep_ls
    )
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

