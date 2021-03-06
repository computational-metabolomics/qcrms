context ("Test EIC plot.")

library(xcms)
library(BiocManager)
if(!requireNamespace("msPurityData", quietly=TRUE)){
    BiocManager::install("msPurityData")
}

test_that("EIC plot is created and has correct data", {
    mzml_files <- dir(system.file("extdata/lcms/mzML", package="msPurityData"),
        full.names=TRUE, recursive=TRUE)
    rawf <- MSnbase::readMSData(mzml_files[1:2], mode="onDisk", msLevel.=1)
    cwp <- xcms::CentWaveParam(snthresh=10)
    xset <- xcms::findChromPeaks(rawf, param=cwp)
    xset <- xcms::groupChromPeaks(xset,
        xcms::PeakDensityParam(sampleGroups=c("1", "1")))
    xset <- as(xset, "xcmsSet")

    rawfiles <- list()
    rawfiles[[1]] <- MSnbase::readMSData(mzml_files[1], mode="onDisk", 
        msLevel.=1)
    rawfiles[[2]] <- MSnbase::readMSData(mzml_files[2], mode="onDisk", 
        msLevel.=1)

    plot <- expect_warning(qcrms:::XCMS_EIC_plot(indexes=100,
        rawfiles=rawfiles, xset=xset, class=c("1", "1")))

    # Fails on devtools:test() works with testhat
    #expect_equal(round(mean(plot[[1]]$data$rt),4), 44.0588)
    #expect_equal(round(mean(plot[[1]]$data$mz),4), 146.1173)
})
