#' @import xcms
#' @import openxlsx
#' @importFrom dplyr left_join
#' @importFrom  mzR openMSfile
#' @importFrom  mzR tic
#' @importFrom  mzR close
#'
NULL

#' Exctract and return ggplot2 object of EICs for specified xmcm features
#'
#' @param QCreportObject Qcreport object
#' @export


sampleSummary <- function (QCreportObject)
{
  
  if (!is.null(QCreportObject$xset))
  {
    QCreportObject$metaData$table <- QCreportObject$xset@phenoData
  } else {
    QCreportObject$metaData$table <- data.frame(row.names=colnames(QCreportObject$peakMatrix), class=rep(".", ncol(QCreportObject$peakMatrix)))
  }
  
  if (!is.null(QCreportObject$metaData$file))
  {
    if (grepl(".xls", tolower(QCreportObject$metaData$file)) || tolower(tools::file_ext(QCreportObject$metaData$file)) %in% c("xls", "xlsx")){
      if ("metaData" %in% getSheetNames(QCreportObject$metaData$file)){
        sheet = "metaData"
      } else {
        sheet = 1
      }
      metaDataTable <- read.xlsx(xlsxFile = QCreportObject$metaData$file, sheet=sheet)
    } else {
      metaDataTable <- read.table(QCreportObject$metaData$file, header=TRUE, check.names=FALSE)
    }
    QCreportObject$metaData$table$Sample = rownames(QCreportObject$metaData$table)
    QCreportObject$metaData$table <- left_join(QCreportObject$metaData$table, metaDataTable, by="Sample")
  } else
  {
    colnames(QCreportObject$metaData$table) <- QCreportObject$metaData$classColumn
    QCreportObject$metaData$table[,1] <- as.vector(QCreportObject$metaData$table[,1])
    QCreportObject$metaData$table$Sample <- rownames(QCreportObject$metaData$table)

    if (!is.null(QCreportObject$Blank_label))
      {
        bh <- grep(QCreportObject$Blank_label, rownames(QCreportObject$metaData$table))
        if (length(bh)>0) QCreportObject$metaData$table[bh,1] <- QCreportObject$Blank_label
      }
    if (!is.null(QCreportObject$QC_label))
      { qh <- grep(QCreportObject$QC_label, rownames(QCreportObject$metaData$table))
        if (length(qh)>0) QCreportObject$metaData$table[qh,1] <- QCreportObject$QC_label
      }
  }

  if (!is.null(QCreportObject$raw_path))
  {
    QCreportObject$raw_paths <- paste(QCreportObject$raw_path,"/",QCreportObject$metaData$table$Sample,".mzML",sep="")
  } else if (!is.null(QCreportObject$xset)) {
    QCreportObject$raw_paths <- QCreportObject$xset@filepaths
  }
  
  # TimeStamp from mzML file
  
  QCreportObject$timestamps <- rep(NA, length(QCreportObject$raw_paths))
  
  for (i in 1:length(QCreportObject$raw_paths))
  {
    if(file.exists(QCreportObject$raw_paths[i]))
    {
      QCreportObject$timestamps[i] <- qcrms::mzML.startTimeStamp(filename = QCreportObject$raw_paths[i])
    }
  }

  chit <- which(colnames(QCreportObject$metaData$table)==QCreportObject$metaData$classColumn)

  # Quick and dirty sample classes from file names
  QCreportObject$QC_hits <- which(QCreportObject$metaData$table[,chit]==QCreportObject$QC_label)
  QCreportObject$Blank_hits <- which(QCreportObject$metaData$table[,chit]==QCreportObject$Blank_label)

  QCreportObject$metaData$samp_lab <- QCreportObject$metaData$table[,chit]

  QCreportObject$TICs <- rep(NA, nrow(QCreportObject$metaData$table))
  QCreportObject$TICraw <- rep(NA, nrow(QCreportObject$metaData$table))
  QCreportObject$TICdata <- vector("list", nrow(QCreportObject$metaData$table))

  if (!is.null(QCreportObject$xset))
  {
    peakt <- QCreportObject$xset@peaks
    
    peaksDetected <- as.vector(table(peakt[,11]))
    
    #TIC for extracted peaks
    QCreportObject$TICs <- tapply (peakt[,7], peakt[,11], FUN=sum)
  
    # TIC's for raw files
    # mzR is anout 10 times faster to read Raw data files than MSnbase implementation. So for tic needs I am using it.
    for (sn in 1:length(QCreportObject$TICraw))
    {
      if (file.exists(QCreportObject$raw_paths[i]))
      {
        A <- mzR::openMSfile(QCreportObject$raw_paths[sn])
        tic <- mzR::tic(A)
        QCreportObject$TICraw[sn] <- sum(tic$TIC)
        QCreportObject$TICdata[[sn]] <- tic$TIC
        mzR::close(A)
        rm (A, tic)
      }
    }
  } else {
    peaksDetected = as.vector(apply(QCreportObject$peakMatrix, 2, function(x) length(which(!is.na(x)))))
    QCreportObject$TICs = colSums(QCreportObject$peakMatrix, na.rm = TRUE, dims = 1)
    QCreportObject$TICraw = colSums(QCreportObject$peakMatrix, na.rm = TRUE, dims = 1)
    QCreportObject$TICdata = vector("list", ncol(QCreportObject$peakMatrix))
  }
  
  QCreportObject$metaData$samp_lab <- as.factor (QCreportObject$metaData$samp_lab)

  QCreportObject$samp.sum <- data.frame(sample=QCreportObject$metaData$table$Sample, 
                                        meas.time=QCreportObject$timestamps,
                                        class=QCreportObject$metaData$samp_lab,
                                        peaks.detected=peaksDetected)

  colnames (QCreportObject$samp.sum) <- c("Sample","Measurement time","Class","Number of peaks")

  QCreportObject$samp.sum <- QCreportObject$samp.sum[order(QCreportObject$timestamps),]
  row.names(QCreportObject$samp.sum) <- NULL

  rNames <- c("Number of samples:", "Sample classes:")
  cValues <-  c((nrow(QCreportObject$metaData$table)),
              paste(unique(QCreportObject$metaData$table[,chit]), collapse=", "))

  QCreportObject$projectHeader <- rbind(QCreportObject$projectHeader,c("",""),cbind (rNames, cValues))

  QCreportObject
}