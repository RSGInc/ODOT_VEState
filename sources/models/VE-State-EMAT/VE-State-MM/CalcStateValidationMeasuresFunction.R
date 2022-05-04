#============================================================
#Define function to calculate state model validation measures
#============================================================

calcStateValidationMeasures <- 
  function(Years, BaseYear, DstoreLocs_ = c("Datastore"), DstoreType = "RD") {
    
    #Prepare for datastore queries
    #-----------------------------
    QPrep_ls <- prepareForDatastoreQuery(
      DstoreLocs_ = DstoreLocs_,
      DstoreType = DstoreType
    )
    
    #================================================
    #DEFINE FUNCTION TO CALCULATE MEASURES FOR A YEAR
    #================================================
    calcStateMeasures <- function(Year) {

      #--------------------------------------------------
      #Define function to create a data frame of measures
      #--------------------------------------------------
      makeMeasureDataFrame <- function(DataNames_, Year) {
        Data_X <- t(t(sapply(DataNames_, function(x) get(x))))
        colnames(Data_X) <- Year
        Measures_ <- rownames(Data_X)
        Units_ <- 
          unname(sapply(DataNames_, function(x) attributes(get(x))$Units))
        Description_ <- 
          unname(sapply(DataNames_, function(x) attributes(get(x))$Description))
        Data_df <- cbind(
          Measure = Measures_,
          data.frame(Data_X),
          Units = Units_,
          Description = Description_
        )
        rownames(Data_df) <- NULL
        colnames(Data_df) <- c("Measure", Year, "Units", "Description")
        Data_df
      }
      
      #-----------------------------------------
      #Population, Income, and Per Capita Income
      #-----------------------------------------
      #Population
      Population <- summarizeDatasets(
        Expr = "sum(HhSize)",
        Units_ = c(
          HhSize = "PRSN"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(Population) <- list(
        Units = "persons",
        Description = "Total population"
      )
      #Households
      Households <- summarizeDatasets(
        Expr = "count(HhSize)",
        Units_ = c(
          HhSize = "PRSN"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(Households) <- list(
        Units = "households",
        Description = "Total households"
      )
      #Households less than 25K hh income
      HouseholdsIncLess25K <- summarizeDatasets(
        Expr = "sum(Income < 25000)",
        Units_ = c(
          Income = "USD"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdsIncLess25K) <- list(
        Units = "households",
        Description = "Households earning less than 25K"
      )
      #Households between 25K to 50K hh income
      HouseholdsInc25Kto50K <- summarizeDatasets(
        Expr = "sum((Income >= 25000) & (Income < 50000))",
        Units_ = c(
          Income = "USD"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdsInc25Kto50K) <- list(
        Units = "households",
        Description = "Households earning between 25K to 50K"
      )
      #Households over 50K hh income
      HouseholdsIncOver50K <- Households - HouseholdsIncLess25K - HouseholdsInc25Kto50K
      attributes(HouseholdsIncOver50K) <- list(
        Units = "households",
        Description = "Households earning over 50K"
      )
      
      
      
      # #Income
      # Income <- summarizeDatasets(
      #   Expr = "sum(Income)",
      #   Units_ = c(
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Income) <- list(
      #   Units = paste(BaseYear, "dollars per year"),
      #   Description = "Total personal income"
      # )
      # #Per Capita Income
      # PerCapInc <- Income / Population
      # attributes(PerCapInc) <- list(
      #   Units = paste(BaseYear, "dollars per person per year"),
      #   Description = "Average per capita income"
      # )
      
      #----
      #DVMT
      #----
      #Household DVMT
      HouseholdDvmt <- summarizeDatasets(
        Expr = "sum(Dvmt)",
        Units = c(
          Dvmt = "MI/DAY"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdDvmt) <- list(
        Units = "miles per day",
        Description = "Total DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters"
      )
      
      #Households DVMT less than 25K hh income
      HouseholdDvmtIncLess25K <- summarizeDatasets(
        Expr = "sum(Dvmt[Income < 25000])",
        Units_ = c(
          Income = "USD",
          Dvmt = "MI/DAY"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdDvmtIncLess25K) <- list(
        Units = "miles per day",
        Description = "Total DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters with hh income less than 25K"
      )
      #Households between 25K to 50K hh income
      HouseholdDvmtInc25Kto50K <- summarizeDatasets(
        Expr = "sum(Dvmt[(Income >= 25000) & (Income < 50000)])",
        Units_ = c(
          Income = "USD",
          Dvmt = "MI/DAY"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdDvmtInc25Kto50K) <- list(
        Units = "miles per day",
        Description = "Total DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters with hh income between 25K to 50K"
      )
      #Households over 50K hh income
      HouseholdDvmtIncOver50K <- HouseholdDvmt - HouseholdDvmtIncLess25K - HouseholdDvmtInc25Kto50K
      attributes(HouseholdDvmtIncOver50K) <- list(
        Units = "miles per day",
        Description = "Total DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters with hh income over 50K"
      )
      
      
      # Dvmt per household
      HouseholdDvmtPerHh <- HouseholdDvmt/Households
      attributes(HouseholdDvmtPerHh) <- list(
        Units = "miles per day per household",
        Description = "Average household DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters"
      )

      HouseholdDvmtPerHhIncLess25K <- HouseholdDvmtIncLess25K /HouseholdsIncLess25K
      attributes(HouseholdDvmtPerHhIncLess25K) <- list(
        Units = "miles per day per household",
        Description = "Average household DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters with earnings less than 25K"
      )
      HouseholdDvmtPerHhInc25Kto50K <- HouseholdDvmtInc25Kto50K /HouseholdsInc25Kto50K
      attributes(HouseholdDvmtPerHhInc25Kto50K) <- list(
        Units = "miles per day per household",
        Description = "Average household DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters with earnings between 25K to 50K"
      )
      HouseholdDvmtPerHhIncOver50K <- HouseholdDvmtIncOver50K /HouseholdsIncOver50K
      attributes(HouseholdDvmtPerHhIncOver50K) <- list(
        Units = "miles per day per household",
        Description = "Average household DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters with earnings over 50K"
      )
      
      # Dvmt per capita
      HouseholdDvmtPerPrsn <- HouseholdDvmt/Population
      attributes(HouseholdDvmtPerPrsn) <- list(
        Units = "miles per day per capita",
        Description = "Average per capita household DVMT (in owned and car service vehicles) of persons in households and non-institutional group quarters"
      )
      
      #Household Car Service DVMT
      HouseholdCarSvcDvmt <- summarizeDatasets(
        Expr = "sum(Dvmt[VehicleAccess != 'Own'] * DvmtProp[VehicleAccess != 'Own'])",
        Units = c(
          Dvmt = "MI/DAY",
          DvmtProp = "",
          VehicleAccess = ""
        ),
        Table = list(
          Household = c("Dvmt"),
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
      
      # Household car service DVMT per household
      HouseholdCarSvcDvmtPerHh <- HouseholdCarSvcDvmt/Households
      attributes(HouseholdCarSvcDvmtPerHh) <- list(
        Units = "miles per day per household",
        Description = "Average household DVMT in car service vehicles of persons in households and non-institutional group quarters"
      )
      
      # Household car service DVMT per capita
      HouseholdCarSvcDvmtPerPrsn <- HouseholdCarSvcDvmt/Population
      attributes(HouseholdCarSvcDvmtPerPrsn) <- list(
        Units = "miles per day per capita",
        Description = "Per capita household DVMT in car service vehicles of persons in households and non-institutional group quarters"
      )
      
      
      #Commercial Service DVMT
      ComSvcDvmt <- summarizeDatasets(
        Expr = "sum(ComSvcUrbanDvmt) + sum(ComSvcTownDvmt) + sum(ComSvcRuralDvmt)",
        Units = c(
          ComSvcUrbanDvmt = "MI/DAY",
          ComSvcTownDvmt = "MI/DAY",
          ComSvcRuralDvmt = "MI/DAY"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(ComSvcDvmt) <- list(
        Units = "miles per day",
        Description = "Total DVMT of commercial service vehicles"
      )
      # #Public Transit Van DVMT
      # PTVanDvmt <- summarizeDatasets(
      #   Expr = "sum(VanDvmt)",
      #   Units = c(
      #     VanDvmt = "MI/DAY"
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(PTVanDvmt) <- list(
      #   Units = "miles per day",
      #   Description = "Total DVMT of public transit vans"
      # )
      # #Light-duty Vehicle DVMT
      # LdvDvmt <- HouseholdDvmt + ComSvcDvmt + PTVanDvmt
      # attributes(LdvDvmt) <- list(
      #   Units = "miles per day",
      #   Description = "Total DVMT of household vehicles, commercial service vehicles, and public transit vans"
      # )
      # #Heavy truck DVMT
      # HvyTruckDvmt <- summarizeDatasets(
      #   Expr = "sum(HvyTrkUrbanDvmt) + sum(HvyTrkNonUrbanDvmt)",
      #   Units = c(
      #     HvyTrkUrbanDvmt = "MI/DAY",
      #     HvyTrkNonUrbanDvmt = "MI/DAY"
      #   ),
      #   Table = "Region",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(HvyTruckDvmt) <- list(
      #   Units = "miles per day",
      #   Description = "Total DVMT of heavy trucks"
      # )
      # #Bus DVMT
      # BusDvmt <- summarizeDatasets(
      #   Expr = "sum(BusDvmt)",
      #   Units = c(
      #     BusDvmt = "MI/DAY"
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(BusDvmt) <- list(
      #   Units = "miles per day",
      #   Description = "Total DVMT of public transit busses"
      # )
      # #Heavy duty vehicle DVMT
      # HdvDvmt <- HvyTruckDvmt + BusDvmt
      # attributes(HdvDvmt) <- list(
      #   Units = "miles per day",
      #   Description = "Total DVMT of heavy trucks and public transit busses"
      # )
      # #Total DVMT
      # TotalDvmt <- LdvDvmt + HdvDvmt
      # attributes(HdvDvmt) <- list(
      #   Units = "miles per day",
      #   Description = "Total DVMT of light-duty vehicles and heavy duty vehicles"
      # )
      
      #----------------
      #Gasoline Gallons
      #----------------
      #Household daily GGE
      HouseholdGGE <- summarizeDatasets(
        Expr = "sum(DailyGGE)",
        Units_ = c(
          DailyGGE = "GGE/DAY"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdGGE) <- list(
        Units = "gallons per day",
        Description = "Total gasoline consumed by household vehicles"
      )
      #Household daily GGE
      # HouseholdGGEMetro <- summarizeDatasets(
      #   Expr = "sum(DailyGGE[Marea=='Metro'])",
      #   Units_ = c(
      #     DailyGGE = "GGE/DAY",
      #     Marea = ""
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(HouseholdGGEMetro) <- list(
      #   Units = "gallons per day",
      #   Description = "Total gasoline consumed by household vehicles in Metro"
      # )
      #Commercial Service Vehicle GGE
      ComSvcGGE <- summarizeDatasets(
        Expr = "sum(ComSvcNonUrbanGGE) + sum(ComSvcUrbanGGE)",
        Units_ = c(
          ComSvcNonUrbanGGE = "GGE/DAY",
          ComSvcUrbanGGE = "GGE/DAY"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(ComSvcGGE) <- list(
        Units = "gallons per day",
        Description = "Total gasoline consumed by commercial service vehicles"
      )
      # ComSvcGGEMetro <- summarizeDatasets(
      #   Expr = "sum(ComSvcNonUrbanGGE[Marea=='Metro']) + sum(ComSvcUrbanGGE[Marea=='Metro'])",
      #   Units_ = c(
      #     ComSvcNonUrbanGGE = "GGE/DAY",
      #     ComSvcUrbanGGE = "GGE/DAY",
      #     Marea=""
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(ComSvcGGEMetro) <- list(
      #   Units = "gallons per day",
      #   Description = "Total gasoline consumed by commercial service vehicles in Metro"
      # )
      #Public Transit Van GGE
      PTVanGGE <- summarizeDatasets(
        Expr = "sum(VanGGE)",
        Units_ = c(
          VanGGE = "GGE/DAY"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(PTVanGGE) <- list(
        Units = "gallons per day",
        Description = "Total gasoline consumed by public transit vans"
      )
      # PTVanGGEMetro <- summarizeDatasets(
      #   Expr = "sum(VanGGE[Marea=='Metro'])",
      #   Units_ = c(
      #     VanGGE = "GGE/DAY",
      #     Marea=""
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(PTVanGGEMetro) <- list(
      #   Units = "gallons per day",
      #   Description = "Total gasoline consumed by public transit vans in Metro"
      # )
      #Bus GGE
      BusGGE <- summarizeDatasets(
        Expr = "sum(BusGGE)",
        Units_ = c(
          BusGGE = "GGE/DAY"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(BusGGE) <- list(
        Units = "gallons per day",
        Description = "Total gasoline consumed by public transit busses"
      )
      # BusGGEMetro <- summarizeDatasets(
      #   Expr = "sum(BusGGE[Marea=='Metro'])",
      #   Units_ = c(
      #     BusGGE = "GGE/DAY",
      #     Marea=""
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(BusGGE) <- list(
      #   Units = "gallons per day",
      #   Description = "Total gasoline consumed by public transit busses in Metro"
      # )
      #Total GGE
      TotalGGE <- HouseholdGGE + ComSvcGGE + PTVanGGE + BusGGE
      attributes(TotalGGE) <- list(
        Units = "gallons per day",
        Description = "Total gasoline consumed by light and heavy duty vehicles"
      )
      #Total GGE per capita
      TotalGGEPerCapita <- TotalGGE/Population
      attributes(TotalGGEPerCapita) <- list(
        Units = "gallons per day per capita",
        Description = "Per capita gasoline consumed by light and heavy duty vehicles"
      )
      # #Total GGE in Metro
      # TotalGGEMetro <- HouseholdGGEMetro + ComSvcGGEMetro + PTVanGGEMetro + BusGGEMetro
      # attributes(TotalGGEMetro) <- list(
      #   Units = "gallons per day",
      #   Description = "Total gasoline consumed by light and heavy duty vehicles in Metro"
      # )
      # TotalGGENonMetro <- TotalGGE - TotalGGEMetro
      # attributes(TotalGGENonMetro) <- list(
      #   Units = "gallons per day",
      #   Description = "Total gasoline consumed by light and heavy duty vehicles in Non-Metro"
      # )
      LdvAveSpeed <- summarizeDatasets(
        Expr = "mean(LdvAveSpeed, na.rm=TRUE)",
        Units_ = c(
          LdvAveSpeed = "MI/HR"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(LdvAveSpeed) <- list(
        Units = "Miles per Hour",
        Description = "Average speed (miles per hour) of light-duty vehicle travel"
      )
      
      #-------------------
      #Light-Duty Vehicles
      #-------------------
      # NumHouseholdVehicles <- summarizeDatasets(
      #   Expr = "sum(NumAuto) + sum(NumLtTrk)",
      #   Units_ =  c(
      #     NumAuto = "VEH",
      #     NumLtTrk = "VEH"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(NumHouseholdVehicles) <- list(
      #   Units = "vehicles",
      #   Description = "Number of vehicles owned or leased by households"
      # )
      # 
      # #----------
      # #Population
      # #----------
      # Age0to14 = summarizeDatasets(
      #   Expr = "sum(Age0to14)",
      #   Units_ = c(
      #     Age0to14 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Age0to14) <- list(
      #   Units = "persons",
      #   Description = "Number of persons age 0 to 14"
      # )
      # Age15to19 = summarizeDatasets(
      #   Expr = "sum(Age15to19)",
      #   Units_ = c(
      #     Age15to19 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Age15to19) <- list(
      #   Units = "persons",
      #   Description = "Number of persons age 15 to 19"
      # )
      # Age20to29 = summarizeDatasets(
      #   Expr = "sum(Age20to29)",
      #   Units_ = c(
      #     Age20to29 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Age20to29) <- list(
      #   Units = "persons",
      #   Description = "Number of persons age 20 to 29"
      # )
      # Age30to54 = summarizeDatasets(
      #   Expr = "sum(Age30to54)",
      #   Units_ = c(
      #     Age30to54 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Age30to54) <- list(
      #   Units = "persons",
      #   Description = "Number of persons age 30 to 54"
      # )
      # Age55to64 = summarizeDatasets(
      #   Expr = "sum(Age55to64)",
      #   Units_ = c(
      #     Age55to64 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Age55to64) <- list(
      #   Units = "persons",
      #   Description = "Number of persons age 55 to 64"
      # )
      # Age65Plus = summarizeDatasets(
      #   Expr = "sum(Age65Plus)",
      #   Units_ = c(
      #     Age65Plus = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Age65Plus) <- list(
      #   Units = "persons",
      #   Description = "Number of persons age 65 and older"
      # )
      # TotalPopulation = summarizeDatasets(
      #   Expr = "sum(HhSize)",
      #   Units_ = c(
      #     HhSize = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(TotalPopulation) <- list(
      #   Units = "persons",
      #   Description = "Number of persons"
      # )
      # 
      # #-------
      # #Drivers
      # #-------
      # Drv15to19 = summarizeDatasets(
      #   Expr = "sum(Drv15to19)",
      #   Units_ = c(
      #     Drv15to19 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Drv15to19) <- list(
      #   Units = "persons",
      #   Description = "Number of licensed drivers age 15 to 19"
      # )
      # Drv20to29 = summarizeDatasets(
      #   Expr = "sum(Drv20to29)",
      #   Units_ = c(
      #     Drv20to29 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Drv20to29) <- list(
      #   Units = "persons",
      #   Description = "Number of licensed drivers age 20 to 29"
      # )
      # Drv30to54 = summarizeDatasets(
      #   Expr = "sum(Drv30to54)",
      #   Units_ = c(
      #     Drv30to54 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Drv30to54) <- list(
      #   Units = "persons",
      #   Description = "Number of licensed drivers age 30 to 54"
      # )
      # Drv55to64 = summarizeDatasets(
      #   Expr = "sum(Drv55to64)",
      #   Units_ = c(
      #     Drv55to64 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Drv55to64) <- list(
      #   Units = "persons",
      #   Description = "Number of licensed drivers age 55 to 64"
      # )
      # Drv65Plus = summarizeDatasets(
      #   Expr = "sum(Drv65Plus)",
      #   Units_ = c(
      #     Drv65Plus = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Drv65Plus) <- list(
      #   Units = "persons",
      #   Description = "Number of licensed drivers age 65 and older"
      # )
      # TotalDrivers = summarizeDatasets(
      #   Expr = "sum(Drivers)",
      #   Units_ = c(
      #     Drivers = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(TotalDrivers) <- list(
      #   Units = "persons",
      #   Description = "Number of licensed drivers"
      # )
      # 
      # #-------
      # #Workers
      # #-------
      # Wkr15to19 = summarizeDatasets(
      #   Expr = "sum(Wkr15to19)",
      #   Units_ = c(
      #     Wkr15to19 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Wkr15to19) <- list(
      #   Units = "persons",
      #   Description = "Number of workers age 15 to 19"
      # )
      # Wkr20to29 = summarizeDatasets(
      #   Expr = "sum(Wkr20to29)",
      #   Units_ = c(
      #     Wkr20to29 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Wkr20to29) <- list(
      #   Units = "persons",
      #   Description = "Number of workers age 20 to 29"
      # )
      # Wkr30to54 = summarizeDatasets(
      #   Expr = "sum(Wkr30to54)",
      #   Units_ = c(
      #     Wkr30to54 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Wkr30to54) <- list(
      #   Units = "persons",
      #   Description = "Number of workers age 30 to 54"
      # )
      # Wkr55to64 = summarizeDatasets(
      #   Expr = "sum(Wkr55to64)",
      #   Units_ = c(
      #     Wkr55to64 = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Wkr55to64) <- list(
      #   Units = "persons",
      #   Description = "Number of workers age 55 to 64"
      # )
      # Wkr65Plus = summarizeDatasets(
      #   Expr = "sum(Wkr65Plus)",
      #   Units_ = c(
      #     Wkr65Plus = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(Wkr65Plus) <- list(
      #   Units = "persons",
      #   Description = "Number of workers age 65 and older"
      # )
      # TotalWorkers = summarizeDatasets(
      #   Expr = "sum(Workers)",
      #   Units = c(
      #     Workers = "PRSN"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(TotalWorkers) <- list(
      #   Units = "persons",
      #   Description = "Number of workers"
      # )
      # 
      # #---------------------------------------
      # #Average Light-duty Vehicle Fuel Economy
      # #---------------------------------------
      # AverageLdvMpg <- LdvDvmt / (HouseholdGGE + ComSvcGGE + PTVanGGE)
      # attributes(AverageLdvMpg) <- list(
      #   Units = "miles per gallon",
      #   Description = "Average fuel economy of light-duty vehicles"
      # )
      
      #----------------------------------------------
      #Average Light-duty Vehicle GHG Emissions Rates
      #----------------------------------------------
      #Household daily CO2e
      HouseholdCO2e <- summarizeDatasets(
        Expr = "sum(DailyCO2e)",
        Units_ = c(
          DailyCO2e = "GM/DAY"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdCO2e) <- list(
        Units = "grams per day",
        Description = "Daily greenhousehouse gas emissions of household vehicles"
      )
      HouseholdCO2ePerCapita <- HouseholdCO2e / Population
      attributes(HouseholdCO2ePerCapita) <- list(
        Units = "grams per day per capita",
        Description = "Per capita Daily greenhousehouse gas emissions of household vehicles"
      )
      
      HouseholdCO2eUrban <- summarizeDatasets(
        Expr = "sum(DailyCO2e[LocType=='Urban'])",
        Units_ = c(
          DailyCO2e = "GM/DAY",
          LocType = "category"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdCO2eUrban) <- list(
        Units = "grams per day",
        Description = "Daily greenhousehouse gas emissions of household vehicles in urban area"
      )
      
      HouseholdCO2eRural <- summarizeDatasets(
        Expr = "sum(DailyCO2e[LocType=='Rural'])",
        Units_ = c(
          DailyCO2e = "GM/DAY",
          LocType = "category"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(HouseholdCO2eRural) <- list(
        Units = "grams per day",
        Description = "Daily greenhousehouse gas emissions of household vehicles in Rural area"
      )
      
      PopulationUrban <- summarizeDatasets(
        Expr = "sum(HhSize[LocType=='Urban'])",
        Units_ = c(
          HhSize = "PRSN",
          LocType = "category"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(PopulationUrban) <- list(
        Units = "person",
        Description = "Urban population"
      )
      
      PopulationRural <- summarizeDatasets(
        Expr = "sum(HhSize[LocType=='Rural'])",
        Units_ = c(
          HhSize = "PRSN",
          LocType = "category"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(PopulationRural) <- list(
        Units = "person",
        Description = "Rural population"
      )
      
      HouseholdCO2ePerCapitaUrban <- HouseholdCO2eUrban/PopulationUrban
      HouseholdCO2ePerCapitaRural <- HouseholdCO2eRural/PopulationRural
      
      
      attributes(HouseholdCO2ePerCapitaUrban) <- list(
        Units = "grams per day",
        Description = "Per capita greenhousehouse gas emissions of household vehicles in urban area"
      )
      attributes(HouseholdCO2ePerCapitaRural) <- list(
        Units = "grams per day",
        Description = "Per capita greenhousehouse gas emissions of household vehicles in rural area"
      )
      
      # #Commercial Service Vehicle CO2e
      # ComSvcCO2e <- summarizeDatasets(
      #   Expr = "sum(ComSvcNonUrbanCO2e) + sum(ComSvcUrbanCO2e)",
      #   Units_ = c(
      #     ComSvcNonUrbanCO2e = "GM/DAY",
      #     ComSvcUrbanCO2e = "GM/DAY"
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(ComSvcCO2e) <- list(
      #   Units = "grams per day",
      #   Description = "Daily greenhousehouse gas emissions of commercial service vehicles"
      # )
      # #Public Transit Van CO2e
      # PTVanCO2e <- summarizeDatasets(
      #   Expr = "sum(VanCO2e)",
      #   Units_ = c(
      #     VanCO2e = "GM/DAY"
      #   ),
      #   Table = "Marea",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(PTVanCO2e) <- list(
      #   Units = "grams per day",
      #   Description = "Daily greenhousehouse gas emissions of public transit vans"
      # )
      # #Light-duty Vehicle CO2e
      # LdvCO2e <- HouseholdCO2e + ComSvcCO2e + PTVanCO2e
      # attributes(LdvCO2e) <- list(
      #   Units = "grams per day",
      #   Description = "Daily greenhousehouse gas emissions of light-duty vehicles"
      # )
      # #HouseholdCO2eRate
      # HouseholdCO2eRate <- HouseholdCO2e / HouseholdDvmt
      # attributes(HouseholdCO2eRate) <- list(
      #   Units = "grams per mile",
      #   Description = "Average greenhousehouse gas emissions rate of household vehicles"
      # )
      # #ComSvcCO2eRate
      # ComSvcCO2eRate <- ComSvcCO2e / ComSvcDvmt
      # attributes(ComSvcCO2eRate) <- list(
      #   Units = "grams per mile",
      #   Description = "Average greenhousehouse gas emissions rate of commercial service vehicles"
      # )
      # #PTVanCO2eRate
      # PTVanCO2eRate <- PTVanCO2e / PTVanDvmt
      # attributes(PTVanCO2eRate) <- list(
      #   Units = "grams per mile",
      #   Description = "Average greenhousehouse gas emissions rate of public transit vans"
      # )
      # #LdvCO2eRate
      # LdvCO2eRate <- LdvCO2e / LdvDvmt
      # attributes(LdvCO2eRate) <- list(
      #   Units = "grams per mile",
      #   Description = "Average greenhousehouse gas emissions rate of light-duty vehicles"
      # )
      
      #---------------------------------------
      #Household trips characteristics
      #---------------------------------------
      
      # Transit
      TransitTrips <- summarizeDatasets(
        Expr = "sum(TransitTrips)",
        Units_ = c(
          TransitTrips = "TRIPS/YR"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(TransitTrips) <- list(
        Units = "trips per year",
        Description = "Annual total household transit trips in 2050"
      )
      # TransitTripsHHLess25K <- summarizeDatasets(
      #   Expr = "sum(TransitTrips[Income < 25000])",
      #   Units_ = c(
      #     TransitTrips = "TRIPS/YR",
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(TransitTripsHHLess25K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household transit trips by household earning less than 25K in 2050"
      # )
      # TransitTripsHH25Kto50K <- summarizeDatasets(
      #   Expr = "sum(TransitTrips[(Income >= 25000) & (Income < 50000)])",
      #   Units_ = c(
      #     TransitTrips = "TRIPS/YR",
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(TransitTripsHH25Kto50K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household transit trips by household earning between 25K to 50K in 2050"
      # )
      # TransitTripsHHOver50K <- TransitTrips - TransitTripsHHLess25K - TransitTripsHH25Kto50K
      # attributes(TransitTripsHHOver50K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household transit trips by household earning over 50K in 2050"
      # )
      
      TransitTripsPerCapita <- TransitTrips/Population
      attributes(TransitTripsPerCapita) <- list(
        Units = "trips per year per capita",
        Description = "Annual transit trips per capita"
      )
      
      # Bike
      BikeTrips <- summarizeDatasets(
        Expr = "sum(BikeTrips)",
        Units_ = c(
          BikeTrips = "TRIPS/YR"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(BikeTrips) <- list(
        Units = "trips per year",
        Description = "Annual total household bike trips in 2050"
      )
      # BikeTripsHHLess25K <- summarizeDatasets(
      #   Expr = "sum(BikeTrips[Income < 25000])",
      #   Units_ = c(
      #     BikeTrips = "TRIPS/YR",
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(BikeTripsHHLess25K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household bike trips by household earning less than 25K in 2050"
      # )
      # BikeTripsHH25Kto50K <- summarizeDatasets(
      #   Expr = "sum(BikeTrips[(Income >= 25000) & (Income < 50000)])",
      #   Units_ = c(
      #     BikeTrips = "TRIPS/YR",
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(BikeTripsHH25Kto50K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household bike trips by household earning between 25K to 50K in 2050"
      # )
      # BikeTripsHHOver50K <- BikeTrips - BikeTripsHHLess25K - BikeTripsHH25Kto50K
      # attributes(BikeTripsHHOver50K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household bike trips by household earning over 50K in 2050"
      # )
      
      BikeTripsPerCapita <- BikeTrips/Population
      attributes(BikeTripsPerCapita) <- list(
        Units = "trips per year per capita",
        Description = "Annual bike trips per capita"
      )
      
      # Walk
      WalkTrips <- summarizeDatasets(
        Expr = "sum(WalkTrips)",
        Units_ = c(
          WalkTrips = "TRIPS/YR"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(WalkTrips) <- list(
        Units = "trips per year",
        Description = "Annual total household walk trips in 2050"
      )
      # WalkTripsHHLess25K <- summarizeDatasets(
      #   Expr = "sum(WalkTrips[Income < 25000])",
      #   Units_ = c(
      #     WalkTrips = "TRIPS/YR",
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(WalkTripsHHLess25K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household walk trips by household earning less than 25K in 2050"
      # )
      # WalkTripsHH25Kto50K <- summarizeDatasets(
      #   Expr = "sum(WalkTrips[(Income >= 25000) & (Income < 50000)])",
      #   Units_ = c(
      #     WalkTrips = "TRIPS/YR",
      #     Income = "USD"
      #   ),
      #   Table = "Household",
      #   Group = Year,
      #   QueryPrep_ls = QPrep_ls
      # )
      # attributes(WalkTripsHH25Kto50K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household walk trips by household earning between 25K to 50K in 2050"
      # )
      # WalkTripsHHOver50K <- WalkTrips - WalkTripsHHLess25K - WalkTripsHH25Kto50K
      # attributes(WalkTripsHHOver50K) <- list(
      #   Units = "trips per year",
      #   Description = "Annual total household walk trips by household earning over 50K in 2050"
      # )
      
      WalkTripsPerCapita <- WalkTrips/Population
      attributes(WalkTripsPerCapita) <- list(
        Units = "trips per year per capita",
        Description = "Annual walk trips per capita"
      )
      
      #---------------------------------------
      #Congestion characteristics
      #---------------------------------------
      # Extreme Congestion
      MetroFwyDvmtPropExtCong <- summarizeDatasets(
        Expr = "mean(FwyDvmtPropExtCong[Marea=='Metro'])",
        Units_ = c(
          FwyDvmtPropExtCong = "proportion",
          Marea = ""
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(MetroFwyDvmtPropExtCong) <- list(
        Units = "proportion",
        Description = "Proportion of freeway DVMT occurring when congestion is extreme in Metro area in 2050"
      )
      # Severe Congestion
      MetroFwyDvmtPropSevCong <- summarizeDatasets(
        Expr = "mean(FwyDvmtPropSevCong[Marea=='Metro'])",
        Units_ = c(
          FwyDvmtPropSevCong = "proportion",
          Marea = ""
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(MetroFwyDvmtPropSevCong) <- list(
        Units = "proportion",
        Description = "Proportion of freeway DVMT occurring when congestion is severe in Metro area in 2050"
      )
      
      
      #---------------------------------------
      #Safety measures
      #---------------------------------------
      
      # Fatal crashes
      AutoFatalUrban <- summarizeDatasets(
        Expr = "sum(AutoFatalCrashUrban)",
        Units_ = c(
          AutoFatalCrashUrban = "CRASH"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(AutoFatalUrban) <- list(
        Units = "CRASH/YR",
        Description = "Number of yearly atuo fatal crashes in Urban area in 2050"
      )
      
      AutoFatalRural <- summarizeDatasets(
        Expr = "sum(AutoFatalCrashRural)",
        Units_ = c(
          AutoFatalCrashRural = "CRASH"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(AutoFatalRural) <- list(
        Units = "CRASH/YR",
        Description = "Number of yearly atuo fatal crashes in Rural area in 2050"
      )
      
      # Injury crashes
      AutoInjuryUrban <- summarizeDatasets(
        Expr = "sum(AutoInjuryCrashUrban)",
        Units_ = c(
          AutoInjuryCrashUrban = "CRASH"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(AutoInjuryUrban) <- list(
        Units = "CRASH/YR",
        Description = "Number of yearly atuo fatal crashes in Urban area in 2050"
      )
      
      AutoInjuryRural <- summarizeDatasets(
        Expr = "sum(AutoInjuryCrashRural)",
        Units_ = c(
          AutoInjuryCrashRural = "CRASH"
        ),
        Table = "Marea",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(AutoInjuryRural) <- list(
        Units = "CRASH/YR",
        Description = "Number of yearly atuo fatal crashes in Rural area in 2050"
      )
      
      #---------------------------------------
      #Vehicle Ownership Cost
      #---------------------------------------
      
      # Ownership Cost
      OwnCostProp <- summarizeDatasets(
        Expr = "mean(OwnCost/Income)",
        Units_ = c(
          OwnCost = "USD",
          Income = "USD"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(OwnCostProp) <- list(
        Units = "proportion",
        Description = "Vehicle ownerhsip cost as a proportion of household income in 2050"
      )
      
      
      OwnCostPropHhLess25K <- summarizeDatasets(
        Expr = "mean((OwnCost/Income)[Income < 25000])",
        Units_ = c(
          OwnCost = "USD",
          Income = "USD"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(OwnCostPropHhLess25K) <- list(
        Units = "proportion",
        Description = "Vehicle ownerhsip cost as a proportion of household income for households earning less than 25K in 2050"
      )
      
      OwnCostPropHh25Kto50K <- summarizeDatasets(
        Expr = "mean((OwnCost/Income)[(Income >= 25000) & (Income < 50000)])",
        Units_ = c(
          OwnCost = "USD",
          Income = "USD"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(OwnCostPropHh25Kto50K) <- list(
        Units = "proportion",
        Description = "Vehicle ownerhsip cost as a proportion of household income for households earning between 25K to 50K in 2050"
      )
      
      OwnCostPropHhOver50K <- summarizeDatasets(
        Expr = "mean((OwnCost/Income)[Income >= 50000])",
        Units_ = c(
          OwnCost = "USD",
          Income = "USD"
        ),
        Table = "Household",
        Group = Year,
        QueryPrep_ls = QPrep_ls
      )
      attributes(OwnCostPropHhOver50K) <- list(
        Units = "proportion",
        Description = "Vehicle ownerhsip cost as a proportion of household income for households earning over 50K in 2050"
      )
      
      
      #---------------------------------------
      #Data frame of household characteristics
      #---------------------------------------
      YearData_df <- makeMeasureDataFrame(
        DataNames_ = c(
          # "Population",
          # "Income",
          # "PerCapInc",
          # "HouseholdDvmt",
          # "HouseholdDvmtPerHh",
          # "HouseholdDvmtPerPrsn",
          # "HouseholdDvmtPerHhIncLess25K",
          # "HouseholdDvmtPerHhInc25Kto50K",
          # "HouseholdDvmtPerHhIncOver50K",
          # "HouseholdCarSvcDvmt",
          # "HouseholdCarSvcDvmtPerHh",
          # "HouseholdCarSvcDvmtPerPrsn",
          # "ComSvcDvmt",
          # "PTVanDvmt",
          # "LdvDvmt",
          # "HvyTruckDvmt",
          # "BusDvmt",
          # "HdvDvmt",
          # "TotalDvmt",
          # "TotalGGE",
          # "TotalGGEPerCapita",
          # "TotalGGEMetro",
          # "TotalGGENonMetro",
          # "NumHouseholdVehicles",
          # "Age0to14",
          # "Age15to19",
          # "Age20to29",
          # "Age30to54",
          # "Age55to64",
          # "Age65Plus",
          # "Drv15to19",
          # "Drv20to29",
          # "Drv30to54",
          # "Drv55to64",
          # "Drv65Plus",
          # "TotalDrivers",
          # "Wkr15to19",
          # "Wkr20to29",
          # "Wkr30to54",
          # "Wkr55to64",
          # "Wkr65Plus",
          # "TotalWorkers",
          # "AverageLdvMpg",
          # "HouseholdCO2e",
          # "HouseholdCO2ePerCapita",
          # "ComSvcCO2e",
          # "PTVanCO2e",
          # "LdvCO2e",
          # "HouseholdCO2eRate",
          # "HouseholdCO2eRate",
          # "ComSvcCO2eRate",
          # "PTVanCO2eRate",
          # "LdvCO2eRate",
          # "TransitTripsPerCapita",
          # "TransitTripsHHLess25K",
          # "TransitTripsHH25Kto50K",
          # "TransitTripsHHOver50K",
          # "BikeTripsPerCapita",
          # "BikeTripsHHLess25K",
          # "BikeTripsHH25Kto50K",
          # "BikeTripsHHOver50K",
          # "WalkTripsPerCapita"
          # "WalkTripsHHLess25K",
          # "WalkTripsHH25Kto50K",
          # "WalkTripsHHOver50K"
          "HouseholdDvmtPerHh",
          "HouseholdDvmtPerPrsn",
          "HouseholdCarSvcDvmtPerHh",
          "HouseholdCarSvcDvmtPerPrsn",
          "TransitTripsPerCapita",
          "BikeTripsPerCapita",
          "WalkTripsPerCapita",
          "ComSvcDvmt",
          "MetroFwyDvmtPropExtCong",
          "MetroFwyDvmtPropSevCong",
          "LdvAveSpeed",
          "AutoFatalUrban",
          "AutoInjuryUrban",
          "AutoFatalRural",
          "AutoInjuryRural",
          "HouseholdDvmtPerHhIncLess25K",
          "HouseholdDvmtPerHhInc25Kto50K",
          "HouseholdDvmtPerHhIncOver50K",
          "OwnCostProp",
          "OwnCostPropHhLess25K",
          "OwnCostPropHh25Kto50K",
          "OwnCostPropHhOver50K",
          "TotalGGEPerCapita",
          "HouseholdCO2ePerCapita",
          "HouseholdCO2ePerCapitaUrban",
          "HouseholdCO2ePerCapitaRural"
        ),
        Year = Year
      )
      
    }
    
    Results_ls <- list()
    for (Year in Years) {
      Results_ls[[Year]] <- calcStateMeasures(Year)
    }
    
    Values_df <- data.frame(do.call(cbind, lapply(Results_ls, function(x) x[,2])))
    names(Values_df) <- Years
    
    Results_df <- cbind(
      Measure = Results_ls[[1]]$Measure,
      Values_df,
      Units = Results_ls[[1]]$Units,
      Description = Results_ls[[1]]$Description
    )
    
    Results_df
    
  }