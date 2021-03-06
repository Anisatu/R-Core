#!/usr/bin/Rsript
# ---------------------------------------------------------#
# Filename      : DGEA.R                                   #
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anisa  #
# Description   : GSEA Interaction Network Pathways        #
# Rscript gage_interaction_networks.R --rundir ~/Desktop/ --pathid "hsa00480"
# ---------------------------------------------------------#

#############################################################################
#                        Import Libraries                                   #
#############################################################################

# load required libraries and silence library loading messages on command line
suppressMessages(library("argparser"))     # Argument passing
suppressMessages(library("Cairo"))         # Plots saving
suppressMessages(library("gage"))          # Does the analysis
suppressMessages(library("gageData"))      # Lets data be used by gage
suppressMessages(library("GEOquery"))      # GEO dataset Retrieval
suppressMessages(library("GO.db"))         # Loads GO database
suppressMessages(library("pathview"))      # Interaction networks & used to get ENTREZ IDs

#############################################################################
#                        Command Line Arguments                             #
#############################################################################

# set parsers for all input arguments
parser <- arg_parser("Interaction Network parameters:")

# General Parameters
parser <- add_argument(parser, "--rundir",
                       help = "The output directory where graphs get saved")
parser <- add_argument(parser, "--pathid",
                       help = "Interaction Network Path ID")

# allows arguments to be run via the command line
argv <- parse_args(parser)

#############################################################################
#                        Command Line Arguments Retrieval                   #
#############################################################################

# General Parameters
run.dir          <- argv$rundir
pathid          <- argv$pathid

# Check if the run directory exists and if not, exit...
if (!dir.exists(file.path(run.dir))) {
  print("ERROR: The Run Directory does not exist.")
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Loading Saved Dataset                            #
#############################################################################

filename <- file.path(run.dir, "gage.RData")

if (file.exists(filename)){
    load(file = filename)
    if(geneset.type != "KEGG"){
        # Exit with error code 1
        print("ERROR:Interaction Network supports only for KEGG Database.")
        quit(save = "no", status = 1, runLast = FALSE)
    }
}else {
    # Exit with error code 1
    print("ERROR:File not found.Run gage analysis first to see interaction networks")
    quit(save = "no", status = 1, runLast = FALSE)
}


#############################################################################
#                          Interaction Networks                             #
#############################################################################

if(analysis.type == "ExpVsCtrl"){

    #Find expression change between experimental group and control
    GEOdataset.diff<-geo.dataset[, Group1] - rowMeans(geo.dataset[, Group2])

    # Save png and xml files in current working directory
    pathview(gene.data = GEOdataset.diff[, 1:2], pathway.id = pathid,
             species = keggcode.organism, out.suffix = "gage_pathway")

}else if(analysis.type =="ExpVsExp"){

    # Interaction pathways for experimental group 1
    pathview(gene.data = geo.dataset[, Group1names][, 1:2], pathway.id = pathid,
             species = keggcode.organism, out.suffix = "gage_pathway")

    # Interaction pathways for experimental group 2
    pathview(gene.data = geo.dataset[, Group2names][, 1:2], pathway.id = pathid,
             species = keggcode.organism, out.suffix = "gage_pathway")

}
