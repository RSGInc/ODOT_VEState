#Set the model folder
#setwd(paste0(getwd(),"/models/TEST"))

# Set the year
Yr<-c("2005","2010","2015", "2020","2040")
#Yr <- Years

#Identify all the files in the model folder
FileLists<-list.files(getwd())

#Set the final desired output for counties
County_Measures_AllYrs<-NULL
for(i in Yr) {
    j<-paste0("County_measures_",i,".csv")
    temp<-read.csv(FileLists[FileLists %in% j])
    temp$Year<-i
    temp$No<-c(1:nrow(temp))
    temp<-temp[,c(ncol(temp)-1,ncol(temp),1,c(3:(ncol(temp)-4)),2,c(3:(ncol(temp)-2)))]
    County_Measures_AllYrs<-rbind(County_Measures_AllYrs,temp)
    rm(temp)
    }

#write out the fianl desired outputs
write.csv(County_Measures_AllYrs,"County_Measures_AllYrs.csv")

  