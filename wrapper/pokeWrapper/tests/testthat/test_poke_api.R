context("Testing poke_api call functions correctly")

# testing that the poke_api funciton is able to connect to the pokeAPI
test_that("poke_api connection is working",{
  apistatus <- poke_api('/pokemon/1')$status_code
  # A status code of 200 indicates a succesful call to the pokeAPI
  expect_equal(apistatus, 200)
  # Stop the test if the api call didn't work (everything else depends on the API having worked)
  stopifnot(apistatus == 200)
  # Testing failure
  expect_output(poke_api('/pokemon/0'), "Error: Invalid Input Path")
  expect_output(poke_api(500), "Error: Unable to reach API")
})
