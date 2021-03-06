#' @importFrom SummarizedExperiment assay
#' @importFrom S4Vectors metadata
NULL

#' Wrapper function to transform data for statistical analysis
#'
#' @param Data Data frame.
#' @param classes Vector of class labels.
#' @param blank Label used for blank samples, if set to NULL no samples will be
#' removed.
#' @param PQN Can be set to T or F, to perform PQN normalisation.
#' @param mv_impute T or F, indicates if missing value imputation has to be
#' carried.
#' @param glogScaling T or F, applie glog transformation to the given data.
#' @param qc_label Label used for QC samples. If set to NULL, assumes that no
#'QC samples are present in data set.
#' @param ignorelabel Label for samples which should be excluded from processed
#' data.
#' @param checkNA removes rows or columns containing all NA's, also will chek
#' if only all QC or analytical samples contain missing values.
#' @param store_lambda If value of glog optimised lambda parameter needs to be
#' returned.
#' @return List of processed data table and RSD% per sample class.
#' @export

prepareData <- function(Data, classes, blank="BLANK", PQN=FALSE,
  mv_impute=TRUE, glogScaling=TRUE, qc_label="QC", ignorelabel="Removed",
  checkNA=TRUE, store_lambda=FALSE) {

    Data <- pmp:::check_input_data(df=Data, classes=classes)

    rem_samples <- NULL
    if (!is.null(blank)) {
      rem_samples <- which(classes == blank)
    }

    if (!is.null(ignorelabel)) {
      rem_samples <- append(rem_samples, which(classes == ignorelabel))
    }

    if (length(rem_samples) > 0L) {

      Data <- Data[, -c(rem_samples)]
      classes <- classes[-c(rem_samples)]
    }

    # Remove rows (features) with all NA's in QC sample or in analytical
    # sample. It can happen if we process data from more than one batch.

    if (checkNA == TRUE) {

      AllNa <- function(x) all(is.na(x))

      if (is.null(qc_label)) {
        hits2 <-
          which(apply(SummarizedExperiment::assay(Data), 1L, AllNa) == TRUE)
      } else {
        hits2 <- which(apply(SummarizedExperiment::
          assay(Data)[, classes == qc_label], 1L, AllNa) == TRUE)
        hits2 <- append(hits2, which(apply(SummarizedExperiment::assay(Data)
          [, -c(which(classes == qc_label))], 1L, AllNa) == TRUE))
        hits2 <- unique(hits2)
      }

      if (length(hits2) > 0L) {
        Data <- Data[-c(hits2), ]
      }
    }

    RSD <- do_variability_list(peak_data=Data, classes=classes)

    #pqn normalisation
    if (PQN == TRUE & !is.null(qc_label)) {
      Data <- pmp::pqn_normalisation(df=Data, classes=classes,
        qc_label=qc_label)
    }

    # mv imputation
    if (mv_impute == TRUE) {
      Data <- pmp::mv_imputation(Data, "knn", k=5L, rowmax=1L, colmax=1L,
        maxp=NULL, check_df=FALSE)
    }

    #glog scaling
    if (glogScaling == TRUE & !is.null(qc_label)) {
      if (store_lambda) {
        Data <- glog_transformation(df=Data, classes=classes, qc_label=qc_label)
        lambda <-
          S4Vectors::metadata(Data)$
            processing_history$glog_transformation$lambda_opt
      } else {
        Data <- glog_transformation(df=Data, classes=classes, qc_label=qc_label)
        lambda <-NULL
      }
    } else {
      lambda <- NULL
    }

    S4Vectors::metadata(Data)$original_data_structure <- "matrix"
    Data <- pmp:::return_original_data_structure(Data)

    out <- list(Data, classes, RSD, lambda)
    names(out) <- c("Data", "classes", "RSD", "glog_lambda")
    out
}
