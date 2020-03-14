db_state <- future.tests:::db_state
stop_if_not <- future.tests:::stop_if_not
options(future.tests.debug = TRUE)

message("*** db_state() ...")

res <- db_state("list")
str(res)

res <- db_state("reset")
str(res)

stack <- db_state("list")
str(stack)
stop_if_not(length(stack) == 1L)

res <- db_state("push", title = "abc")
str(res)

options(foo = 42L)
Sys.setenv(BAR = "3.14")

stack <- db_state("list")
str(stack)
stop_if_not(length(stack) == 2L)

res <- db_state("push", title = "def")
str(res)

stack <- db_state("list")
str(stack)
stop_if_not(length(stack) == 3L)

res <- db_state("pop")
str(res)

stack <- db_state("list")
str(stack)
stop_if_not(length(stack) == 2L)

res <- db_state("pop")
str(res)

stack <- db_state("list")
str(stack)
stop_if_not(length(stack) == 1L)

message("*** db_state() ... DONE")
