library(devtools)
devtools::install_github("nguyeneva/data534_project/pokeWrapper")

library(pokeWrapper)

pokeframe <- initializeDataFrame()

?poke.filter
?pokeframe

head(pokeframe)

poke.filter(pokeframe, "jigglypuff")

poke.filter(pokeframe, c("dragonite","snorlax"))

poke.summary(pokeframe, 'habitat')

poke.summary(pokeframe, 'type')

habitatSummary <- poke.summary(pokeframe, 'habitat')
barplot(habitatSummary$pokemonCount, names.arg=habitatSummary$habitat, las=2,col="#FFCC33")
par(mar=c(7,3,3,0))
mtext(side=3, line=0.5, "Count of Pokémon by Habitat", col="red", font=3, cex=2)
mtext(side=1, line=4.5, "Habitat", col="blue", font=2,cex=1.2)
mtext(side=2, line=2, "Count of Pokémon", col="blue", font=2, cex=1.2)


<<<<<<< HEAD
?summary()
?initializeDataFrame()
?poke.filter()
=======

>>>>>>> 8defa58a55ff9a744fb6893eabff4b7218fad0b2

