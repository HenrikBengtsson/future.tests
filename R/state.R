#' @importFrom grDevices dev.list dev.off
#' @importFrom future plan
#' @importFrom utils str
db_state <- local({
  state_empty <- list(
    title = NULL,
    envir = new.env(),
    vars  = character(0L),
    envs  = list(),
    opts  = list(),
    devs  = NULL,
    plan  = NULL
  )
  stack <- list(state_empty)
  
  function(action = c("reset", "list", "push", "pop"), title = NULL, envir = parent.frame()) {
    action <- match.arg(action)

    debug <- getOption("future.tests.debug", FALSE)

    if (debug) {
      mdebug("db_state('%s') ...", action)
      mdebug("- stack depth: %d", length(stack))
    }

    res <- NULL
    
    if (action == "reset") {
      stack <<- list(state_empty)
      stop_if_not(length(stack) == 1L)
    } else if (action == "list") {
      return(stack)
    } else if (action == "push") {
      ## Record original state of ls(), env vars, and options
      state <- list(
        title = title,
        envir = envir,
        vars  = mget(ls(envir = envir), envir = envir),
        envs  = Sys.getenv(),
        opts  = options(),
        devs  = dev.list(),
        plan  = plan("list")
      )
#      message("*** ", state$title, " ...")

      if (debug) str(state)
      old_depth <- length(stack)
      if (debug) str(stack)
      stack <<- c(list(state), stack)
      if (debug) str(stack)
      stop_if_not(length(stack) == old_depth + 1L)
    } else if (action == "pop") {
      stop_if_not(length(stack) >= 1L)

      old_depth <- length(stack)
      state <- stack[[1L]]
      if (debug) str(state)
      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo graphics devices
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      added <- setdiff(dev.list(), state$devs)
      if (length(added) > 0) {
	if (debug) {
	  labels <- sprintf("%s (%d)", sQuote(names(added)), added)
	  mdebug("Closing newly opened graphics devices: [n=%d] %s",
	         length(added), paste(labels, collapse = ", "))
	}
        lapply(added, FUN = dev.off)
      }
      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo options
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## If new options were added, then remove them
      added <- setdiff(names(options()), names(state$opts))
      if (length(added) > 0) {
        opts <- vector("list", length = length(added))
        names(opts) <- added
	if (debug) {
	  mdebug("Removing newly added options: %s",
	         paste(sQuote(names(opts)), collapse = ", "))
#          mstr(opts)
	}

        ## Remove options
	## WORKAROUND: Not all options can be removed, e.g. option
	## 'warnPartialMatchArgs' does not exists in a fresh R session,
	## but cannot be removed; it can only be set to FALSE or TRUE.
	## Because of this, we need to use tryCatch().
        tryCatch(options(opts), error = identity)
      }

      ## Reset to originally, recorded options
      options(state$opts)
      
      ## Assert that everything was properly undone
      ## NOTE: This is not possible, because not all options can be unset,
      ## e.g. 'warnPartialMatchArgs' (see above)
      ## stop_if_not(identical(options(), state$opts))

      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo system environment variables
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## If new env vars were added, then remove them
      envs <- Sys.getenv()
      added <- setdiff(names(envs), names(state$envs))
      if (length(added) > 0) {
	if (debug) {
	  mdebug("Removing newly added environment variables: %s",
	         paste(sQuote(added), collapse = ", "))
	}
        for (name in added) Sys.unsetenv(name)
      }	
      
      ## If env vars were dropped, add then back
      missing <- setdiff(names(state$envs), names(envs))
      if (length(missing) > 0)
        do.call(Sys.setenv, as.list(state$envs[missing]))
      
      ## If env vars were Modified, reset them
      for (name in intersect(names(envs), names(state$envs))) {
        ## WORKAROUND: On Linux Wine, base::Sys.getenv() may
        ## return elements with empty names. /HB 2016-10-06
        if (nchar(name) == 0) next
        
        if (!identical(envs[[name]], state$envs[[name]]))
          do.call(Sys.setenv, as.list(state$envs[name]))
      }
      
      ## Assert that everything was properly undone
      stop_if_not(identical(Sys.getenv(), state$envs))

      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo variables
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## If new objects were added, then remove them
      added <- c(setdiff(ls(envir = state$envir), state$vars))
      if (length(added) > 0) {
	if (debug) {
	  mdebug("Removing newly added variables: %s",
	         paste(sQuote(added), collapse = ", "))
	}
        rm(list = added, envir = state$envir, inherits = FALSE)
      }	

      ## If objects were modified or dropped, reset them
      for (name in names(state$vars))
        assign(name, state$vars[[name]], envir = state$envir)
      
      ## Assert that everything was properly undone
      stop_if_not(identical(ls(envir = state$envir), names(state$vars)))
      for (name in names(state$vars)) {
        stop_if_not(identical(
          get(name, envir = state$envir, inherits = FALSE),
          state$vars[[name]]
        ))
      }
      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo future strategy
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if (!is.null(state$plan)) {
        ## WORKAROUND: https://github.com/HenrikBengtsson/future/issues/320
        state_plan <- state$plan
        plan(state_plan)

        ## Assert that everything was properly undone
        stop_if_not(identical(plan("list"), state$plan))
      }

#      message("*** ", state$title, " ... DONE")

      ## Drop old state
      stack <<- stack[-1L]
      stop_if_not(length(stack) == old_depth - 1L)
    }
    
    if (debug) {
      mdebug("- stack depth: %d", length(stack))
      mdebug("db_state('%s') ... done", action)
    }

    invisible(res)
  }
})

push_state <- function(title = NULL, envir = parent.frame()) {
  db_state(action = "push", title = title, envir = envir)
}

pop_state <- function() {
  db_state(action = "pop")
}
