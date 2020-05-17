context("Testing poke.summary and poke.filter functions")

# Initializing the pokeframe through API calls takes a long time, so testing functions that use the pokeframe is done from a csv dataframe
# So that they CRAN server doesn't get too many requesets
pokeframe <- read_csv("pokeframe.csv")

# Testing the possible outputs of the poke.summary function
test_that("summary function is summarizing the data correctly",{
  expect_equal_to_reference(poke.summary(pokeframe, 'habitat'), 'habitat.rds')
  expect_equal_to_reference(poke.summary(pokeframe, 'type'), 'type.rds')
  expect_output(poke.summary(pokeframe, 'test'), "Invalid Request")
})

# Testing the possible outputs of the poke.filter function
test_that("poke.filter function is filtering the data correctly", {
  # Creating lists of items to be populated in test dataframes
  idx <- c(39, 25, 7, 4, 1)
  pokemon <- c('jigglypuff', 'pikachu', 'squirtle', 'charmander', 'bulbasaur')
  speciesURL<- c('https://pokeapi.co/api/v2/pokemon-species/39/', 'https://pokeapi.co/api/v2/pokemon-species/25/',
                 'https://pokeapi.co/api/v2/pokemon-species/7/', 'https://pokeapi.co/api/v2/pokemon-species/4/',
                 'https://pokeapi.co/api/v2/pokemon-species/1/')
  habitat <- c('grassland', 'forest', 'waters-edge', 'mountain', 'grassland')
  captureRate <- c(170, 190, 45, 45, 45)
  type <- c('fairy, normal', 'electric', 'water', 'fire', 'poison, grass')
  moves <- c('pound,double-slap,mega-punch,fire-punch,ice-punch', 'mega-punch,pay-day,thunder-punch,slam,mega-kick',
             'mega-punch,ice-punch,mega-kick,headbutt,tackle', 'mega-punch,fire-punch,thunder-punch,scratch,swords-dance',
             'razor-wind,swords-dance,cut,bind,vine-whip')
  # Creating Dataframes to compare with the filter output
  testDF <- data.frame(idx, pokemon, speciesURL, habitat, captureRate, type, moves, stringsAsFactors=FALSE)
  # Testing the poke.filter function when a list of pokemon are passed in
  expect_equal(poke.filter(pokeframe, c("pikachu", "bulbasaur", "charmander", "squirtle")), testDF[-1,])
  # Testing the poke.filter function when a single pokemon is passed in
  expect_equal(poke.filter(pokeframe, "jigglypuff"), testDF[1,])
  # Testing the poke.filter function when one non-generation 1 pokemon is passed in (totodile is generation 2)
  expect_output(poke.filter(pokeframe, "totodile"), "Requested pokemon is not from generation 1")
  # Testing the poke.filter function when multiple non-generation 1 pokemon is passed in (totodile is generation 2)
  expect_output(poke.filter(pokeframe, c("totodile", "chikorita", "cyndaquil")), "Requested pokemon are not from generation 1")
  # Testing the poke.filter function when multiple pokemon are passed in when some are generation 1
  expect_output(poke.filter(pokeframe, c("jigglypuff", "totodile", "chikorita", "cyndaquil")), "Some of the requested pokemon were not generation 1, the generation 1 pokemon are listed below")
  expect_equal(poke.filter(pokeframe, c("jigglypuff", "totodile", "chikorita", "cyndaquil")), testDF[1,])
  # Testing the poke.filter function when the passed in object for pokeframe is not a data frame
  expect_output(poke.filter(pokemon, "jigglypuff"), "pokeframe must be a data frame")
})
