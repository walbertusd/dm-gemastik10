
getData <- function(x) {
	dir <- './data'
	filename <- paste(x, "Rda", sep = ".")
	data <- readRDS(paste(dir, filename, sep = '/'))
}

dat <- do.call(rbind, lapply(1:3652, function(x) getData(x)))
str(dat)

saveRDS(dat, file = './data/train.Rda')

proc.time()

data <- do.call(rbind, lapply(3653:5113, function(x) getData(x)))

saveRDS(data, file = './data/test.Rda')

proc.time()