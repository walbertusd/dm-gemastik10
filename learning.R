library(gbm)
library(Metrics)
dataset <- readRDS('/home/tpratama/Documents/solar-prediction/data/train.Rda')
dataset2 <- readRDS('/home/tpratama/Documents/solar-prediction/data/test.Rda')

train = dataset
test = dataset2

train_arr = data.matrix(train)
test_arr = data.matrix(test)

model <- gbm.fit(x=train_arr[,3:303],
                 y=train_arr[,304],
             distribution = "laplace",
             n.trees = 400,
             shrinkage = 0.03,
             interaction.depth = 3
             )

res <- predict.gbm(model, test_arr[,1:303], 400)
rmse(res, test_arr[,304])
