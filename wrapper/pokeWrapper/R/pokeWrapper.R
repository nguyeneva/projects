ua <- user_agent("https://github.com/nguyeneva/data534_project")
utils::globalVariables(c("pokemon","habitat","captureRate","type","stats","runif"))

# Creating pokeAPI get requests
#'
#' The poke_api() function takes in variable part of the path required
#' for the GET request to the pokeAPI servers.
#'
#' @import jsonlite httr tidyverse stringr dplyr
#'
#' @param path The pokeAPI parameter to pull data for
#'
#' @return The json response from the pokeAPI
#' @export
#'
#' @examples
#' poke_api("/pokemon-species/1")

poke_api <- function(path){
  out <- tryCatch(
    {
      url <- modify_url("https://pokeapi.co", path=paste("/api/v2",path, sep=""))
      response <- GET(url, timeout(10))
      if (http_error(response)){
        if (round(status_code(response)/100,0)==5 | path==500){ # NOTE: all path==500 checks are for testing purposes only (allows simulation of inability to reach API)
          if (path == 500){
            # If 500 was passed in set the response to 500 so that the while loop can be tested
            response = 500
          }
          # If the error status code is in the 500 range attempt to call the API up to 5 more times, with a timed delay between calls
          delayTime <- 1
          while (round(status_code(response)/100,0)==5 & delayTime<=16){
            Sys.sleep(delayTime) # Delay time between calls
            response <- GET(url, timeout(10)) # Attempting to reach the API again
            # Exponential backoff of request time +/- randomly selected value between 0+5% of current delay time
            delayTime = delayTime*2+runif(1, -delayTime*0.05, delayTime*0.05)
            # For Testing when the API can't be reached
          }
          if (round(status_code(response)/100,0)==5 | path==500){
            stop("Unable to reach API", call. = FALSE)
          }
        } else if (round(status_code(response)/100,0)==4){
          stop("Invalid Input Path", call. = FALSE)
        }
      }
      return(response)
    },
  error=function(cond){
    print(gsub("\n","",gettext(cond)))
  })
}

#' Create a Data Frame from pokeAPI call
#'
#' The initializeDataFrame() function sends two get requests to Pokémon API. The API calls
#' return data in the format of JSON and gets parsed by jsonlite. Data from both API
#' calls are appended to a data frame.
#'
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' pokeframe <- initializeDataFrame()
#' }

initializeDataFrame <- function(){
  pokeList <- poke_api("/generation/1")

  # JSON parser
  pokeList <- jsonlite::fromJSON(content(pokeList, "text"), simplifyVector = FALSE)
  numPokemon <- length(pokeList$pokemon_species)

  # Initializing data frame
  pokeframe <- data.frame(idx = 1:numPokemon, pokemon = 1:numPokemon, speciesURL = 1:numPokemon, habitat = 1:numPokemon, captureRate = 1:numPokemon, type = 1:numPokemon, moves=1:numPokemon)
  for ( i in 1:numPokemon){
    # Adding pokemon name, url, and index to the data frame
    pokeframe$pokemon[i] <- pokeList$pokemon_species[[i]]$name
    pokeframe$speciesURL[i] <- pokeList$pokemon_species[[i]]$url
    shortStr <- str_extract(substr(pokeframe$speciesURL[i],nchar(pokeframe$speciesURL[1])-4,nchar(pokeframe$speciesURL[1])), "(?<![0-9])/.*")
    pokeframe$idx[i] <- substr(shortStr,2,nchar(shortStr)-1)
    # First API call
    # Get species info (habitate, capture rate, base happiness)
    currSpecies <- poke_api(paste("/pokemon-species/",pokeframe$idx[i],sep=""))
    currSpecies <- jsonlite::fromJSON(content(currSpecies, "text"), simplifyVector = FALSE)
    pokeframe$habitat[i] <- currSpecies$habitat[[1]]
    pokeframe$captureRate[i] <- currSpecies$capture_rate
    # Second API call
    # Get pokemon type and moves
    currPokemon <- poke_api(paste("/pokemon/",pokeframe$idx[i],sep=""))
    currPokemon <- jsonlite::fromJSON(content(currPokemon, "text"), simplifyVector = FALSE)
    # Get pokemon moves
    move<-vector()
    if (length(currPokemon$moves)<5){
      end <- length(currPokemon$moves)
    } else{
      end <- 5
    }
    for (k in 1:end){
      move<-c(move,currPokemon$moves[[k]]$move$name)
      move<-paste(move,collapse=",")}
    # Get pokemon type
    curType <- currPokemon$types
    type <- ""
    for (j in 1:length(curType)){
      if (j==1){
        type = curType[[j]]$type$name
      } else {
        type = paste(type,", ",curType[[j]]$type$name, sep="")
      }
    }
    # Adding pokemon move to data frame
    pokeframe$moves[i] <- move
    # Adding pokemon type to data frame
    pokeframe$type[i] <- type
    Sys.sleep(1.5)
    cat('\r', i)
  }
  pokeframe
}

#' Create a Data Frame with Aggregated Data from pokeframe
#'
#' The poke.summary() function counts the number of Pokémon and mean of capture rate grouped
#' by either 'habitat' or type' from pokeframe data frame.
#'
#'
#' @param pokeframe The data frame of pokemon to summarise
#' @param infoType The type of information to summarise 'habitat' or 'type'
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' poke.summary(pokeframe, 'habitat')
#' poke.summary(pokeframe, 'type')
#' }

poke.summary <- function(pokeframe, infoType){
  if (infoType == "habitat"){
    # Count of pokemon in each habitat
    group_by(pokeframe, habitat) %>% summarise(pokemonCount=n(), meanCaptureRate=round(mean(captureRate, na.rm = TRUE)))
  } else if (infoType == "type"){
    # Count of pokemon in each type
    group_by(pokeframe, type) %>% summarise(pokemonCount=n(), meanCaptureRate=round(mean(captureRate, na.rm = TRUE)))
  } else{
    print("Invalid Request")
  }
}

#' Create a Data Frame Filtered by Pokémon
#'
#' The poke.filter() function filters the pokeframe data frame by pokemon names
#' selected in a vector,
#'
#'
#' @param pokeframe The data frame of pokemon to summarise
#' @param vec the name(s) of the pokemon being filtered, accepts a string for a single pokemon, or a list for multiple
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' poke.filter(pokeframe, "jigglypuff")
#' poke.filter(pokeframe, c("pikachu", "bulbasaur", "charmander", "squirtle"))
#' }

poke.filter <- function(pokeframe, vec){
  if (is.data.frame(pokeframe)){
    # Checks if the passed in pokeframe is a data frame
    pokeFilter <- subset(pokeframe, pokemon %in% vec)
    if (nrow(pokeFilter) > 0){
      # Checks if any of the pokem  on to be filtered for were in the passed in pokeframe
      if (nrow(pokeFilter) == length(vec)){
        # Returns the filtered dataframe if all pokemon passed in were found
        pokeFilter
      } else{
        # Notifies the user if any pokemon were not found and returns the dataframe of the pokemon that were found
        print("Some of the requested pokemon were not generation 1, the generation 1 pokemon are listed below")
        pokeFilter
      }
    } else{
      # If none of the desired pokemon were found
      if (length(vec)>1){
        # If the filter was for more than 1 pokemon
        print("Requested pokemon are not from generation 1")
      } else{
        # If the filter was for 1 pokemon
        print("Requested pokemon is not from generation 1")
      }
    }
  } else{
    # If the passed in pokeframe isn't a data frame
    print("pokeframe must be a data frame")
  }
}
