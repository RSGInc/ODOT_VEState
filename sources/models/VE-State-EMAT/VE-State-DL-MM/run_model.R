#===========
#run_model.R
#===========

#This script demonstrates the VisionEval framework for the VE-State model.
cat('run_model.R: script entered\n')
#Load libraries
#--------------
library(visioneval)
cat('run_model.R: library visioneval loaded\n')
library(VEReports)

#Initialize model
#----------------
initializeModel(
  ParamDir = "defs",
  RunParamFile = "run_parameters.json",
  GeoFile = "geo.csv",
  ModelParamFile = "model_parameters.json",
  LoadDatastore = TRUE,
  DatastoreName = "Datastore",
  SaveDatastore = TRUE
  )  
cat('run_model.R: initializeModel completed\n')

#Run all demo module for all years
#---------------------------------
for(Year in getYears()) {
  runModule("CreateHouseholds",                "VESimHouseholds",             RunFor = "AllYears",    RunYear = Year)
  runModule("PredictWorkers",                  "VESimHouseholds",             RunFor = "AllYears",    RunYear = Year)
  runModule("AssignLifeCycle",                 "VESimHouseholds",             RunFor = "AllYears",    RunYear = Year)
  runModule("PredictIncome",                   "VESimHouseholds",             RunFor = "AllYears",    RunYear = Year)
  runModule("CreateSimBzones",                 "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("SimulateHousing",                 "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("SimulateEmployment",              "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("Simulate4DMeasures",              "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("SimulateUrbanMixMeasure",         "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("AssignParkingRestrictions",       "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("AssignCarSvcAvailability",        "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("AssignDemandManagement",          "VESimLandUseDL",              RunFor = "AllYears",    RunYear = Year)
  runModule("SimulateTransitService",          "VESimTransportSupply",        RunFor = "AllYears",    RunYear = Year)
  runModule("SimulateRoadMiles",               "VESimTransportSupply",        RunFor = "AllYears",    RunYear = Year)
  runModule("AssignDrivers",                   "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("AssignVehicleOwnership",          "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("AssignVehicleType",               "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("CreateVehicleTable",              "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("AssignVehicleAge",                "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("CalculateVehicleOwnCost",         "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("AdjustVehicleOwnership",          "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("AssignDriverlessVehicles",        "VEHouseholdVehiclesDL",       RunFor = "AllYears",    RunYear = Year)
  runModule("CalculateHouseholdDvmt",          "VETravelDemandMM",            RunFor = "AllYears",    RunYear = Year)
  runModule("CalculateAltModeTrips",           "VETravelDemandMM",            RunFor = "AllYears",    RunYear = Year)
  runModule("CalculateVehicleTrips",           "VEHouseholdTravel",           RunFor = "AllYears",    RunYear = Year)
  runModule("DivertSovTravel",                 "VEHouseholdTravel",           RunFor = "AllYears",    RunYear = Year)
  runModule("CalculateCarbonIntensity",        "VEPowertrainsAndFuelsAP2022", RunFor = "AllYears",    RunYear = Year)
  runModule("AssignHhVehiclePowertrain",       "VEPowertrainsAndFuelsAP2022", RunFor = "AllYears",    RunYear = Year)
  for (i in 1:2) {
    runModule("CalculateRoadDvmt",             "VETravelPerformanceDL",       RunFor = "AllYear",    RunYear = Year)
    runModule("CalculateRoadPerformance",      "VETravelPerformanceDL",       RunFor = "AllYears",    RunYear = Year)
    runModule("CalculateMpgMpkwhAdjustments",  "VETravelPerformanceDL",       RunFor = "AllYears",    RunYear = Year)
    runModule("AdjustHhVehicleMpgMpkwh",       "VETravelPerformanceDL",       RunFor = "AllYears",    RunYear = Year)
    runModule("CalculateVehicleOperatingCost", "VETravelPerformanceDL",       RunFor = "AllYears",    RunYear = Year)
    runModule("BudgetHouseholdDvmt",           "VETravelPerformanceDL",       RunFor = "AllYears",    RunYear = Year)
    #runModule("BalanceRoadCostsAndRevenues",   "VETravelPerformanceDL",       RunFor = "AllYears",    RunYear = Year)
  }
  runModule("CalculateComEnergyAndEmissions",   "VETravelPerformanceDL",      RunFor = "AllYears",    RunYear = Year)
  runModule("CalculatePtranEnergyAndEmissions", "VETravelPerformanceDL",      RunFor = "AllYears",    RunYear = Year)
  runModule("CalculateSafetyMeasures",          "VETravelPerformanceDL",      RunFor = "AllYears",    RunYear = Year)
  runModule("TravelTimeReliability",            "VETravelPerformanceDL",      RunFor = "AllYears",    RunYear = Year)
}


DatastoreName <- readModelState()$DatastoreName
DatastoreType <- readModelState()$DatastoreType
Ma <- unique(readModelState()$Geo$Marea)
Az <- unique(readModelState()$Geo$Azone)
Years <- getYears()
#Tabulate Metro outputs for all years
#------------------------------
if (file.exists("CalcMetroMeasuresFunction.R")) {
  source("CalcMetroMeasuresFunction.R")
  
  for (Year in getYears()) {
    cat(paste0("metro_measures_", Year, ".csv"), "\n")
    write.csv(calcMetropolitanMeasures(Year = Year, Ma = Ma,
                                       DstoreLocs_ = DatastoreName, DstoreType = DatastoreType),
              row.names = FALSE,
              file = file.path("output", paste0("metro_measures_", Year, ".csv")))
  }
  print(paste("Metropolitan measures outputs have been computed for all model",
              "run years and are saved in the following files:",
              paste(paste0("metro_measures_", Years, ".csv"),
                    collapse = ", ")))# can we change this so that it picks up the years itself without user input? (getYears())?
} else {
  warning(paste("Metropolitan measures outputs were not calculated",
                "because the 'CalcMetroMeasuresFunction.R' script is not",
                "present in the same directory as the 'run_model.R' script."))
}

#Tabulate county outputs for all years
#------------------------------
if (file.exists("CalcCountyMeasuresFunction.R")) {
  source("CalcCountyMeasuresFunction.R")
  
  for (Year in getYears()) {
    cat(paste0("county_measures_", Year, ".csv"), "\n")
    write.csv(calcCountyMeasures(Year = Year, Az = Az,
                                       DstoreLocs_ = DatastoreName, DstoreType = DatastoreType),
              row.names = FALSE,
              file = file.path("output", paste0("county_measures_", Year, ".csv")))
  }
  print(paste("County measures outputs have been computed for all model",
              "run years and are saved in the following files:",
              paste(paste0("county_measures_", Years, ".csv"),
                    collapse = ", ")))# can we change this so that it picks up the years itself without user input? (getYears())?
} else {
  warning(paste("County measures outputs were not calculated",
                "because the 'CalcCountyMeasuresFunction.R' script is not",
                "present in the same directory as the 'run_model.R' script."))
}

#Tabulate county-location-type outputs for all years
#---------------------------------------------------
if (file.exists("CalcCountyLocMeasuresFunction.R")) {
  source("CalcCountyLocMeasuresFunction.R")
  
  for (Year in getYears()) {
    cat(paste0("county_location_measures_", Year, ".csv"), "\n")
    write.csv(calcCountyLocMeasures(Year = Year, Az = Az,
                                    DstoreLocs_ = DatastoreName, DstoreType = DatastoreType),
              row.names = FALSE,
              file = file.path("output", paste0("county_location_measures_", Year, ".csv")))
  }
  print(paste("County-location-type measures outputs have been computed for all model",
              "run years and are saved in the following files:",
              paste(paste0("county_measures_", Years, ".csv"),
                    collapse = ", ")))# can we change this so that it picks up the years itself without user input? (getYears())?
} else {
  warning(paste("County-location-type measures outputs were not calculated",
                "because the 'CalcCountyMeasuresFunction.R' script is not",
                "present in the same directory as the 'run_model.R' script."))
}

#Tabulate Statewide outputs for all years
#------------------------------

if (file.exists("CalcStateValidationMeasuresFunction.R")) {
  cat("state_validation_measures.csv", "\n")
  source("CalcStateValidationMeasuresFunction.R")
  #  Years <- c("1990", "1995", "2000", "2005", "2010", "2015", "2020", "2025", "2030", "2035", "2040", "2045", "2050")# can we change this so that it picks up the years itself without user input? (getYears())?
  BaseYear <- "2010"
  write.csv(calcStateValidationMeasures(Years, BaseYear,
                                        DstoreLocs_ = DatastoreName, DstoreType = DatastoreType),
            row.names = FALSE,
            file = file.path("output", "state_validation_measures.csv"))
}else{
  warning(paste("State Validation measures outputs were not calculated",
                "because the 'CalcOregonValidationMeasures.R' script is not",
                "present in the same directory as the 'run_model.R' script."))
}

#source("Combine_metro_measures.R")
# #Tabulate DataStore Inventory
# #------------------------------
# documentDatastoreTables <- function(SaveArchiveName, QueryPrep_ls) {
#   GroupNames_ <- QueryPrep_ls$Listing$Datastore$Datastore$groupname
#   Groups_ <- GroupNames_[-grep("/", GroupNames_)]
#   if (any(Groups_ == "")) {
#     Groups_ <- Groups_[-(Groups_ == "")]
#   }
#   TempDir <- SaveArchiveName
#   dir.create(TempDir)
#   for (Group in Groups_) {
#     GroupDir <- file.path(TempDir, Group)
#     dir.create(GroupDir)
#     Tables_ <- listTables(Group, QueryPrep_ls)$Datastore
#     for (tb in Tables_) {
#       Listing_df <- listDatasets(tb, Group, QueryPrep_ls)$Datastore
#       write.table(Listing_df, file = file.path(GroupDir, paste0(tb, ".csv")),
#                   row.names = FALSE, col.names = TRUE, sep = ",")
#     }
#   }
#   zip(paste0(SaveArchiveName, ".zip"), TempDir)
#   #remove_dir(TempDir)
#   TRUE
# }
# 
# QPrep_ls <- prepareForDatastoreQuery(
#   DstoreLocs_ = DatastoreName,
#   DstoreType = DatastoreType
# )
# documentDatastoreTables("Datastore_Documentation", QPrep_ls)