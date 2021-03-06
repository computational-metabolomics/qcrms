% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepareData.R
\name{prepareData}
\alias{prepareData}
\title{Wrapper function to transform data for statistical analysis}
\usage{
prepareData(
  Data,
  classes,
  blank = "BLANK",
  PQN = FALSE,
  mv_impute = TRUE,
  glogScaling = TRUE,
  qc_label = "QC",
  ignorelabel = "Removed",
  checkNA = TRUE,
  store_lambda = FALSE
)
}
\arguments{
\item{Data}{Data frame.}

\item{classes}{Vector of class labels.}

\item{blank}{Label used for blank samples, if set to NULL no samples will be
removed.}

\item{PQN}{Can be set to T or F, to perform PQN normalisation.}

\item{mv_impute}{T or F, indicates if missing value imputation has to be
carried.}

\item{glogScaling}{T or F, applie glog transformation to the given data.}

\item{qc_label}{Label used for QC samples. If set to NULL, assumes that no
QC samples are present in data set.}

\item{ignorelabel}{Label for samples which should be excluded from processed
data.}

\item{checkNA}{removes rows or columns containing all NA's, also will chek
if only all QC or analytical samples contain missing values.}

\item{store_lambda}{If value of glog optimised lambda parameter needs to be
returned.}
}
\value{
List of processed data table and RSD% per sample class.
}
\description{
Wrapper function to transform data for statistical analysis
}
