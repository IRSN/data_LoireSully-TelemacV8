## Install Funz

library(devtools)
# if needed: `Sys.setenv(HTTPS_PROXY="http://LOGIN:PASSWORD@PROXY_IP:PROXY_PORT")`
install_github("Funz/Funz.R")
library(Funz)
install.Model('Telemac') #append `, edit.script=TRUE` to customize Telemac.sh/.bat script
# Use `setup.Calculators()` to select another Telemac script. Use Telemac-docker.sh/.bat if Telemac is not yet installed (will automatically do it).

# Alternatively, download and install Funz-Telemac manually from https://github.com/Funz/plugin-Telemac/releases

## Check model

# Set parametrized Telemac input directory
MODEL_HOME="LoireSully_model/"
# Check input files
Funz_ParseInput(model='Telemac',
           input.files=c(file.path(MODEL_HOME,'t2d_Loire.cas'), # main input file
                         file.path(MODEL_HOME,'user_fortran'), # force add fortran file
                         file.path(MODEL_HOME,'breach.txt'), # force add breach file
                         file.path(MODEL_HOME,'hydro.txt'))) # hydrogram
