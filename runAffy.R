library(affy)
library(downloader)
library(PharmacoGx)
file.paths <- file.path("/pfs/BrainArray/",c(list.files(pattern="hgu219hsensg*", path="/pfs/BrainArray/"),
                list.files(pattern="pd.hgu219.hs.ensg*", path="/pfs/BrainArray/")))

install.packages(file.paths, repos=NULL, type="source")
ftpdir <- "ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/MTAB/E-MTAB-3610/"

## phenodata
dwl.status <- download(url=sprintf("%s/E-MTAB-3610.sdrf.txt", ftpdir), destfile=file.path("/pfs/out", "E-MTAB-3610.sdrf.txt"), quiet=TRUE)
sampleinfo <- read.csv(file.path("/pfs/out", "E-MTAB-3610.sdrf.txt"), sep="\t", stringsAsFactors=FALSE)

load("/pfs/gdscU219/celfile_timestamp.RData")

rownames(celfile.timestamp) <- basename(rownames(celfile.timestamp))
rownames(celfile.timestamp) <- gsub(rownames(celfile.timestamp), pat=".gz", rep="", fixed=TRUE)

celfn <- list.files(pattern="*.cel.gz", path="/pfs/gdscU219/", full.names=TRUE)

cgp.u219 <- just.rma(filenames=celfn, cdfname="hgu219hsensgcdf")
save(cgp.u219, compress=TRUE, file="/pfs/out/GDSC_U219_ENSG_RAW.RData")
print(head(rownames(pData(cgp.u219))))
colnames(cgp.u219) <- gsub(colnames(cgp.u219), pat=".gz", rep="", fixed=TRUE)
pData(cgp.u219) <- data.frame(pData(cgp.u219), sampleinfo[match(colnames(exprs(cgp.u219)), sampleinfo[ , "Array.Data.File"]), , drop=FALSE], celfile.timestamp[rownames(pData(cgp.u219)), , drop=FALSE])
colnames(exprs(cgp.u219)) <- rownames(pData(cgp.u219)) <- colnames(exprs(cgp.u219))
fData(cgp.u219) <- data.frame("PROBE"=rownames(exprs(cgp.u219)), "GENEID"=sapply(strsplit(rownames(exprs(cgp.u219)), "_"), function (x) { return (x[[1]]) }), "BEST"=TRUE)
rownames(fData(cgp.u219)) <- rownames(exprs(cgp.u219))
cgp.u219.ensg <- cgp.u219

experimentData(cgp.u219.ensg)@preprocessing <- list(Normalisation=list(name="rma", package="affy", version=as.character(packageVersion("affy"))), "Annotation" = list(name="brainarray", package="hgu219hsensgcdf", version=as.character(packageVersion("hgu219hsensgcdf")))) 


save(cgp.u219.ensg, compress=TRUE, file="/pfs/out/GDSC_U219_ENSG.RData")
