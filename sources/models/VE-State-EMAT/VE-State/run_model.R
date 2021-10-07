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
  SaveDatastore = FALSE
  )  
cat('run_model.R: initializeModel completed\n')

#Run all demo module for all years
#---------------------------------
for(Year in getYears()) {
 runModule("CreateHouseholds",                "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
 runModule("PredictWorkers",                  "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
 runModule("AssignLifeCycle",                 "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
 runModule("PredictIncome",                   "VESimHouseholds",       RunFor = "AllYears",    RunYear = Year)
 runModule("CreateSimBzones",                 "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("SimulateHousing",                 "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("SimulateEmployment",              "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("Simulate4DMeasures",              "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("SimulateUrbanMixMeasure",         "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("AssignParkingRestrictions",       "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("AssignCarSvcAvailability",        "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("AssignDemandManagement",          "VESimLandUse",          RunFor = "AllYears",    RunYear = Year)
 runModule("SimulateTransitService",          "VESimTransportSupply",  RunFor = "AllYears",    RunYear = Year)
 runModule("SimulateRoadMiles",               "VESimTransportSupply",  RunFor = "AllYears",    RunYear = Year)
 runModule("AssignDrivers",                   "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("AssignVehicleOwnership",          "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("AssignVehicleType",               "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("CreateVehicleTable",              "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("AssignVehicleAge",                "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("CalculateVehicleOwnCost",         "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("AdjustVehicleOwnership",          "VEHouseholdVehicles",   RunFor = "AllYears",    RunYear = Year)
 runModule("CalculateHouseholdDvmt",          "VEHouseholdTravel",     RunFor = "AllYears",    RunYear = Year)
 runModule("CalculateAltModeTrips",           "VEHouseholdTravel",     RunFor = "AllYears",    RunYear = Year)
 runModule("CalculateVehicleTrips",           "VEHouseholdTravel",     RunFor = "AllYears",    RunYear = Year)
 runModule("DivertSovTravel",                 "VEHouseholdTravel",     RunFor = "AllYears",    RunYear = Year)
 runModule("CalculateCarbonIntensity",        "VEPowertrainsAndFuels", RunFor = "AllYears",    RunYear = Year)
 runModule("AssignHhVehiclePowertrain",       "VEPowertrainsAndFuels", RunFor = "AllYears",    RunYear = Year)
 for (i in 1:2) {
   runModule("CalculateRoadDvmt",             "VETravelPerformance",   RunFor = "AllYear",    RunYear = Year)
   runModule("CalculateRoadPerformance",      "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
   runModule("CalculateMpgMpkwhAdjustments",  "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
   runModule("AdjustHhVehicleMpgMpkwh",       "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
   runModule("CalculateVehicleOperatingCost", "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
   runModule("BudgetHouseholdDvmt",           "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
   runModule("BalanceRoadCostsAndRevenues",   "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
 }
 runModule("CalculateComEnergyAndEmissions",   "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
 runModule("CalculatePtranEnergyAndEmissions", "VETravelPerformance",   RunFor = "AllYears",    RunYear = Year)
}
#Tabulate Metro outputs for all years
#------------------------------
DatastoreName <- readModelState()$DatastoreName
DatastoreType <- readModelState()$DatastoreType
Years <- getYears()
if(!dir.exists("output")) dir.create("output")
if (file.exists("CalcMetroMeasuresFunction.R")) {
  source("CalcMetroMeasuresFunction.R")
  Ma <- unique(readModelState()$Geo$Marea)
  #Years <- getYears()

  for (Year in getYears()) {
    write.csv(calcMetropolitanMeasures(Year = Year, Ma = Ma, DstoreLocs_=DatastoreName, DstoreType=DatastoreType), row.names = FALSE,
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

#Tabulate Statewide outputs for all years
#------------------------------

if (file.exists("CalcStateValidationMeasuresFunction.R")) {
  source("CalcStateValidationMeasuresFunction.R")
#  Years <- c("1990", "1995", "2000", "2005", "2010", "2015", "2020", "2025", "2030", "2035", "2040", "2045", "2050")# can we change this so that it picks up the years itself without user input? (getYears())?
  BaseYear <- readModelState()$BaseYear
  write.csv(calcStateValidationMeasures(Years, BaseYear, DstoreLocs_=DatastoreName, DstoreType=DatastoreType), 
          row.names = FALSE,
          file = file.path("output", "state_validation_measures.csv"))
}else{
  warning(paste("State Validation measures outputs were not calculated",
                "because the 'CalcStateValidationMeasuresFunction.R' script is not",
                "present in the same directory as the 'run_model.R' script."))
}

##Tabulate DataStore Inventory
##------------------------------
#documentDatastoreTables <- function(SaveArchiveName, QueryPrep_ls) {
#  GroupNames_ <- QueryPrep_ls$Listing$Datastore$Datastore$groupname
#  Groups_ <- GroupNames_[-grep("/", GroupNames_)]
#  if (any(Groups_ == "")) {
#    Groups_ <- Groups_[-(Groups_ == "")]
#  }
#  TempDir <- SaveArchiveName
#  dir.create(TempDir)
#  for (Group in Groups_) {
#    GroupDir <- file.path(TempDir, Group)
#    dir.create(GroupDir)
#    Tables_ <- listTables(Group, QueryPrep_ls)$Datastore
#    for (tb in Tables_) {
#      Listing_df <- listDatasets(tb, Group, QueryPrep_ls)$Datastore
#      write.table(Listing_df, file = file.path(GroupDir, paste0(tb, ".csv")),
#                  row.names = FALSE, col.names = TRUE, sep = ",")
#    }
#  }
#  zip(paste0(SaveArchiveName, ".zip"), TempDir)
#  remove_dir(TempDir)
#  TRUE
#}
#
#QPrep_ls <- prepareForDatastoreQuery(
#   DstoreLocs_ = DatastoreName,
#   DstoreType = DatastoreType
# )
# documentDatastoreTables("Datastore_Documentation", QPrep_ls)