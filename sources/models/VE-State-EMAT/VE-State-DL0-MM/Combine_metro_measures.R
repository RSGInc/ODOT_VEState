#Set the model folder
#setwd(paste0(getwd(),"/models/TEST"))

# Set the year
#Yr<-c("1990", "1995", "2000","2005","2010","2015", "2020", "2025", "2030", "2035", "2040", "2045", "2050")
Yr <- Years

#Identify all the files in the model folder
FileLists<-list.files(getwd())

#Set the final desired output for metro
Metro_Measures_AllYrs<-NULL
for(i in Yr) {
    j<-paste0("metro_measures_",i,".csv")
    temp<-read.csv(FileLists[FileLists %in% j])
    temp$Year<-i
    temp$No<-c(1:nrow(temp))
    temp<-temp[,c(ncol(temp)-1,ncol(temp),1,c(3:(ncol(temp)-4)),2,c(11:(ncol(temp)-2)))]
    Metro_Measures_AllYrs<-rbind(Metro_Measures_AllYrs,temp)
    rm(temp)
    }

#write out the fianl desired outputs
write.csv(Metro_Measures_AllYrs,"Metro_Measures_AllYrs.csv")

#From: WEIDNER Tara J <Tara.J.WEIDNER@odot.state.or.us>
#Sent: Tuesday, January 21, 2020 4:29 PM
#To: NGUYEN Thanh N <Thanh.N.NGUYEN@odot.state.or.us>
#Cc: DUDICH Dejan <Dejan.DUDICH@odot.state.or.us>
#Subject: R-script help...

#Thanh -- Would it be possible to help with quick R-scripting of VE outputs? It would be useful for PBOT output as well. Let me know if you can fit this in in next few days.  We could use immediately! Thx - Tara

#In this Cher computer folder, is an example of the current run_model.R script.  At the end (line 68+) you can see we produce marea and statewide summary csv output files.  The 2 improvements we’d like follow:

#1.       Update Line 80 & 92 of the R-script to use the same set of years from earlier in the script, in order to avoid manually change the years listed in these lines.

#2.       Update the marea outputs to concatenate all runyears into a single file, as follows, it should create an output that looks like this desired_output_file from the current by year output that looks like this existing_output_file:

#·       1st field:  *new* “Year”
#·       2nd field: *new* “Measure No.”  
#·       3rd-10th fields:  alphabetically sort marea columns, except with “none” marea as last column (see desired output)
#·       11th & 12th fields: existing “Units” & “Description”

  