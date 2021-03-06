#' @import ggplot2
#' @import scales
#' @import ggthemes
#' @importFrom grDevices rainbow
NULL

#' Ggplot publication theme
#'
#' This ggplot2 theme is modified from original by  Koundinya Desiraju.
#' Availaible from here: https://rpubs.com/Koundy/71792
#'
#' @param base_size Ggplot font size

theme_Publication <- function(base_size=14L) {
  (theme_foundation(base_size=base_size) +
    theme(plot.title=element_text(face="bold",
    size=rel(1.2), hjust=0.5),
    text=element_text(),
    panel.background=element_rect(colour=NA),
    plot.background=element_rect(colour=NA),
    panel.border=element_rect(colour=NA),
    axis.title=element_text(face="bold", size=rel(1L)),
    axis.title.y=element_text(angle=90L, vjust=2L),
    axis.title.x=element_text(vjust=-0.2),
    axis.text=element_text(),
    axis.line=element_line(colour="black"),
    axis.ticks=element_line(),
    panel.grid.major=element_line(colour="#f0f0f0"),
    panel.grid.minor=element_blank(),
    legend.key=element_rect(colour=NA),
    legend.position="bottom",
    legend.direction="horizontal",
    legend.key.size=unit(0.75, "cm"),
    legend.spacing=unit(0.2, "cm"),
    legend.title=element_text(face="italic"),
    plot.margin=unit(c(10L, 5L, 5L, 5L), "mm"),
    strip.background=element_rect(colour="#f0f0f0", fill="#f0f0f0"),
    strip.text=element_text(face="bold")
  ))
}

#' Function to create sorted class labels and colors for reproducable ggplot
#' objects
#'
#' @param class Vector of class labels.
#' @param Blank_label Label used for blank samples, if set to NULL no samples
#' will be removed
#' @param QC_label Label used for QC samples. If set to NULL, assumes that no
#' QC samples are present in data set
#' @param QC_color Color to use for QC samples
#' @param Blank_color Color to use for blank samples
#' @param manual_color Colors to usef for samples classes
#' @return List of processed data table and RSD% per sample class

createClassAndColors <- function(class, QC_label="QC", Blank_label="Blank",
  QC_color="#000000", Blank_color="#A65628",
  manual_color=c("#386cb0", "#ef3b2c", "#7fc97f", "#fdb462",
    "#984ea3", "#a6cee3", "#778899", "#fb9a99", "#ffff33")) {
  if (!is.ordered(class)) {
    reorderNames <- sort(as.character(unique(class)))
  } else {
    reorderNames <- levels(class)
  }

  # if too many levels then use rainbow scale with suitable number of colours
  if (length(reorderNames)>length(manual_color)) {
    manual_color <- grDevices::rainbow(length(reorderNames), alpha=1L)
  }

  hit1 <- which(reorderNames == QC_label)
  if (length(hit1) == 0L) hit1 <- NULL

  hit2 <- which(reorderNames == Blank_label)
  if (length(hit2) == 0L) hit2 <- NULL

  if (!is.null(c(hit1, hit2))) {
    remo <- c(seq_len(length(reorderNames)))[-c(hit1, hit2)]
  } else {
    remo <- c(seq_len(length(reorderNames)))
  }

  reorderNames <- reorderNames[c(hit1, hit2, remo)]

  class <- factor(class, levels=reorderNames, ordered=TRUE)

  extraColors <- NULL
  if (!is.null(hit1)) extraColors[1L] <- QC_color
  if (!is.null(hit2)) extraColors[2L] <- Blank_color

  if (!is.null(extraColors)) extraColors <- extraColors[!is.na(extraColors)]

  out <- list(class=class, manual_colors=c(extraColors, manual_color))
  out
}
