context("test-dosummaryplot")

test_that("dosummaryplot creates ggplot output", {
  out <- doSummaryPlot (Data=testData$data, classes=testData$class,
    plotTitle="PCA", blank=NULL, PQN=FALSE, mv_impute=TRUE, glogScaling=TRUE,
    scale=TRUE, qc_label="QC", ignorelabel="Removed", labels="all", qc_shape=17,
    base_size=10, pccomp=c(1,2), plot=FALSE)
  expect_true(is(out[[1]], "ggplot"))
  expect_true(is(out[[2]], "ggplot"))
})

test_that("dosummaryplot creates ggplot output for several batches", {
  dataList <- list(testData$data[1:15,], testData$data[16:30,])
  classList <- list(testData$class, testData$class)
  titleList <- list("Batch 1", "Batch 2")

  out <- doSummaryPlot (Data=dataList, classes=classList, plotTitle=titleList,
    blank=NULL, PQN=FALSE, mv_impute=TRUE, glogScaling=TRUE, scale=TRUE,
    qc_label=NULL, ignorelabel="Removed", labels="all", qc_shape=17,
    base_size = 10, pccomp=c(1,2), plot=FALSE)
  expect_true(is(out[[1]], "ggplot"))
  expect_true(is(out[[2]], "ggplot"))
  expect_true(is(out[[3]], "ggplot"))
  expect_true(is(out[[4]], "ggplot"))
})

test_that("dosummaryplot stops if input isn't list or data.frame/matrix", {
  expect_error(doSummaryPlot (Data=testData$data[,1], classes=testData$class,
    plotTitle="PCA", blank=NULL, PQN=FALSE, mv_impute=TRUE, glogScaling=TRUE,
    scale=TRUE, qc_label="QC", ignorelabel="Removed", labels="all", qc_shape=17,
    base_size = 10, pccomp=c(1,2), plot=FALSE))
})

test_that("dosummaryplot creates pdf output", {
  output_file <- file.path(tempdir(), "out.pdf")
  out <- expect_warning(qcrms:::doSummaryPlot (Data=qcrms:::testData$data,
    classes=qcrms:::testData$class, plotTitle="PCA", blank=NULL, PQN=FALSE,
    mv_impute=TRUE, glogScaling=TRUE, scale=TRUE, qc_label="QC",
    ignorelabel="Removed", labels="all", qc_shape=17, base_size=10,
    pccomp=c(1,2), plot=TRUE, output=output_file))
  expect_true(file.exists(output_file))
  file.remove(output_file)
})
