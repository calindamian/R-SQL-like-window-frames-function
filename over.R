
library(tidyverse)
library(rlang)

over_frame =  function ( x , 
                         preceding , 
                         following, 
                         fun=NULL 
                         , ...) {
  
  len = length(x)
  
  if (!is.null(preceding) && min(preceding)< 0)
    preceding = len:max(preceding)
  if (!is.null(following) && min(following)< 0)
    following = max(following):len
  
  map (seq_along (x)  , function (i) {
    pre_range = i -preceding
    post_range = i + following
    
    out = c ( x[pre_range[pre_range>=0]]  ,  x[post_range[post_range<=len]] )
    if (! is.null(fun))
      out = fun (out , ...)
    out
  })
  
}

#' Implement a simple window frame capability in R based on existing dplyr
#'
#' @param tb            #input tibble
#' @param col           #tibble column used for calculation
#' @param partition_by  #partition clause (one or multiple columns)
#' @param order_by      #order by clause (one or  multiple columns)
#' @param preceding     #range to specify precedings rows  
#' @param following     #range to specify following rows
#' @param fun           #function to be used on column
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
over = function (tb,
                 col ,
                 partition_by = NULL, 
                 order_by = NULL , 
                 preceding = NULL ,
                 following = NULL ,
                 fun = NULL ,
                 ...) {
  
  #if NULL set to empty string
  partition_by = rlang::parse_exprs(partition_by)
  order_by = rlang::parse_exprs(order_by)
  col =  rlang::parse_expr(col)
  
  tb %>%
    mutate (r.n =1:nrow(tb) )%>%  #set initial order
    group_by(!!! partition_by ) %>%
    arrange(!!! order_by) %>%
    mutate(out.col = over_frame (!!col , preceding , following , fun , ...)  )%>%
    arrange(r.n)%>% #reset initial order
    pull (out.col)
  
}
