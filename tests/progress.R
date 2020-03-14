pcat <- future.tests:::pcat
perase <- future.tests:::perase
preset <- future.tests:::preset

message("*** progress ...")

perase()
cat("\n")

pcat("hello")
cat("\n")
pcat("hello world, how are you?", max_width = 10L)
cat("\n")

preset()
cat("\n")
preset("hello")
cat("\n")

message("*** progress ... DONE")
