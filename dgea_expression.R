#!/usr/bin/Rsript
# ---------------------------------------------------------------------------
# Filename      : DGEA.R
# Authors       : IsmailM, Nazrath, Suresh, Marian, Anissa
# Description   : Retrieve individual gene expressions and convert to JSON
# Run           : Rscript dgea_expression.R  --rundir ~/Desktop/ --geneid LOC100288410
# ---------------------------------------------------------------------------

suppressMessages(library('argparser'))    # Argument passing
suppressMessages(library('jsonlite'))     # Convert R object to JSON format

#############################################################################
#                        Command Line Arguments                             #
#############################################################################

# set parsers for all input arguments
parser <- arg_parser("This parser contains the input arguments")

# General Parameters
parser <- add_argument(parser, "--rundir", help = "Full path to the run directory")
parser <- add_argument(parser, "--geneid", help = "Row Id of the X matrix")

# allow arguments to be run via the command line
argv   <- parse_args(parser)

# Check if the run directory exists and if not, exit...
if (!dir.exists(file.path(argv$rundir))) {
  print("ERROR: The Run Directory does not exist.")
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Loading Saved Dataset                            #
#############################################################################

filename <- file.path(argv$rundir,"dgea_toptable.RData")

if (file.exists(filename)){
  load(file = filename)
} else {
  # Exit with error code 1
  print("ERROR:File not found. Run the analysis first to see Expression Profile")
  quit(save = "no", status = 1, runLast = FALSE)
}

#############################################################################
#                          Retrieve Expression data                         #
#############################################################################

# check directory exists and availability of toptable expression data
if (!is.na(X.toptable)) {
  # get indexes of group 1
  index.group1 <- which((expression.info["population"] == "Group1") == TRUE)
  # get sample names (x) and expression data (y)
  g1 <- list(x = names(X.toptable[argv$geneid, index.group1]),
             y = as.double(X.toptable[argv$geneid, index.group1]))

  # get indexes of group 2
  index.group2 <- which((expression.info["population"] == "Group2") == TRUE)
  # get sample names (x) and expression data (y)
  g2 <- list(x = names(X.toptable[argv$geneid, index.group2]),
             y = as.double(X.toptable[argv$geneid, index.group2]))

  # write to a file
  filename <- file.path(argv$rundir, paste("dgea_", argv$geneid, ".json", sep=''))
  write(toJSON(list(group1 = g1 , group2 = g2)), filename)
} else {
  print("ERROR:File not found or toptable data not found!")
  quit(save = "no", status = 1, runLast = FALSE)
}
