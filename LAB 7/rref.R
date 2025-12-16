library(pracma)

rref.result = matrix(c(-5,-4,12,0,8,-6,-2,0,1,1,1,1), nrow=3, byrow = T) %>% 
  rref()

rref.result[,4] %*% c(0,-4,10) 
rref.result[,4] %*% c(5,0,-2) 
rref.result[,4] %*% c(-3,6,0) 
