## Init Funz

library(Funz)

## Start calculators

calcs = startCalculators(4)
Grid() # Should display 4 calculators

# Alternatively, start from standalone Funz-Telemac install:
# export FUNZ_HOME=/opt/Funz-Telemac
# $FUNZ_HOME/FunzDaemon_start.sh 4

## Calculations

MODEL_HOME="LoireSully_model/" # Telemac input directory

# Latin Hypercube Sampling (1000 cases)

library(DiceDesign) # may require `install.packages('DiceDesign')` first
d=lhsDesign(1000,8,seed=123)$design

# Rescale function from [0,1] to [min,max]
#' @test .from01(matrix(runif(10),ncol=2),newmin=10,newmax=20)
#' @test .from01(matrix(runif(10),ncol=2),newmin=c(10,-10),newmax=c(20,0))
.from01 = function(X01,newmin,newmax) {
  if (!is.matrix(X01)) X01=matrix(X01,nrow=length(X01))
  matrix(newmin,ncol=ncol(X01),nrow=nrow(X01),byrow = T) + X01 * matrix(newmax-newmin,ncol=ncol(X01),nrow=nrow(X01),byrow = T)
}

Run(model='Telemac',
         input.files=c(file.path(MODEL_HOME,'t2d_Loire.cas'),
                       file.path(MODEL_HOME,'user_fortran'),
                       file.path(MODEL_HOME,'breach.txt'),
                       file.path(MODEL_HOME,'hydro.txt')),
         input.variables=list(
            ks2=.from01(d[,1],18,38),
            ks3=.from01(d[,2],27,4), 
            ks4=.from01(d[,3],18,38), 
            ks_fp=.from01(d[,4],5,20), 
            qmax=.from01(d[,5],3000,25000), 
            tm=.from01(d[,6],86400,864000),
            of=.from01(d[,7],0.2,-0.2), 
            er=.from01(d[,8],0,1)),
         all.combinations = FALSE, # not a full factorial with these values !
         output.expressions=c("max(H_parc_chateau)","max(H_centre_sully)","max(H_gare_sully)","max(H_domaine_epinoy)","max(H_caserne_pompiers)"), # Setup interest output values
         archive.dir='LHS1k',verbosity=4, 
         run.control = list(
          force.retry=0, # disable restert when calculation failed
          maxCalcs=30, # limit parallel calcs to 30
          archiveFilter="(.+[^.slf])") # don't keep .slf files in archive
         )

r=.env$.Funz.Last.run
save("r",file="LHS1k.Rdata")                   

## Print maps & write csv

setwd("LHS1k")

for (l in list.dirs(path = getwd(), recursive=FALSE)) {
  print(l)

  mH = NULL
  
  H = read.csv(file.path(l,"output","H_.sully.csv"),header = F)
  mH = matrix(nrow=64, as.matrix(apply(H,2,max)))
  
  png(filename = gsub("LHS1k","LHS1k/..",paste0(l,"_maxH_sully.png")),width = 640,height = 640)
  try( plot(raster(mH)) )
  dev.off()
  
  write.csv(mH,file=gsub("LHS1k","LHS1k/..",paste0(l,"_maxH_sully.csv")))
}

setwd("..")
