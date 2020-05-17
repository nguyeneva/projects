context("Testing initializeDataFrame functionality")

test_that("Data Frame pulled all of the required data",{
  #skip_on_cran() # Not running this test on CRAN as it takes more than 1 minute
  expect_equal_to_reference(initializeDataFrame(), 'pokeframe.rds')
})
