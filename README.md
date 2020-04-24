# R-SQL-like-window-frames-function
R SQL like window frames function

## Overview
The concept behind SQL window frames are wonderfully explained at :
https://mjk.space/advances-sql-window-frames/

The objective is to implement a simple window frame capability in R based on existing 
allready very rich dplyr window functions.

The syntax of the OVER detailed clause is found 
https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver15

My humble implementation looks like this :
```
over = function     (tb,                     #input tibble
                    col ,                    #tibble column used for calculation
                    partition_by = NULL,     #partition clause (one or multiple columns)
                    order_by = NULL ,        #order by clause (one or  multiple columns)
                    preceding = NULL ,       #range to specify precedings rows  
                    following = NULL ,       #range to specify following rows
                    fun = NULL ,             #function to be used on column
                    ...)                     #additional params to fun 
```
## Usage
UNBOUNDED is allways represented as negative number 

CURRENT ROW  is allwas represented as 0 

Relative rows are represented as positive integers 

SQL -> preceding/following params correspondace :

* "ROWS BETWEEN UNBOUNDED PRECEDING  AND CURRENT ROW" ->  preceding=-1:0
* "ROWS BETWEEN  3 PRECEDING AND CURRENT ROW" ->  preceding=3:0
* "ROWS BETWEEN  3 PRECEDING AND 1 PRECEDING" ->  preceding=3:1
* "ROWS BETWEEN  CURRENT ROW AND UNBOUNDED FOLLOWING  " ->  following=0:-1
* "ROWS BETWEEN  3 PRECEDING AND 2 FOLLOWING  " ->  preceding=3:0 , following= 1:2
* "ROWS BETWEEN  3 PRECEDING AND UNBOUNDED FOLLOWING  " ->  preceding=3:0 , following= 1:-1
     
The use of vectorized values for "preceding" and "following" params could cover more use cases than sql.
For exemple "PRECEDING 3 AND PRECEDING 2 AND FOLLOWING  1 AND FOLLOWING  3" 
could not be express in SQL but could be express in current over function as "preceding=3:2 , following= 1:3"

I'll provide some more detailed exemples based on gapminder data.

## Exemples

```
library(gapminder)
library(tidyverse)

source("over.R")


# SQL syntax frame: ROWS BETWEEN UNBOUNDED PRECEDING  AND CURRENT ROW  
# over function : preceding = -1:0  
# if no function is specified returns the vector of values from window frame
gapminder %>%
        arrange(desc (year)) %>% 
        mutate(over_col = 
                          over (.,
                                    col = "lifeExp" ,  
                                    partition_by = "country ; continent" , #one ore multiple cols separated by ";"
                                    order_by = "year" , #one ore multiple cols separated by ";"
                                    preceding = -1:0 ) )   %>% 
        view()


#the same window specification using a sum function 
gapminder %>%
  mutate(over_col = 
                    over (.,
                              col = "lifeExp" , 
                              partition_by = "country" , 
                              order_by = "year" ,
                              preceding = -1:0  ,
                              fun = sum ) ) %>% 
  #unnest(over_col) # unnest col to get the value
  view()
                                
# SQL syntax frame: ROWS BETWEEN  3 PRECEDING  AND CURRENT ROW  
# over function : preceding = 3:0  

gapminder %>%
        mutate(over_col = 
                          over (.,
                                    col = "lifeExp" ,  
                                    partition_by = "country ; continent" ,
                                    order_by = "year" ,
                                    preceding = 3:0 ) )   %>% 
        view()



# SQL syntax frame: ROWS BETWEEN 3  PRECEDING AND 3 FOLLOWING
# over function : preceding = 3:0  
gapminder %>%
        mutate(over_col = 
                          over (.,
                                    col = "lifeExp" ,  
                                    partition_by = "country ; continent" ,
                                    order_by = "year" ,
                                    preceding = 3:0 ,
                                    following = 1:3) )   %>% 
        view()


#fun with params
gapminder %>%
  mutate(over_col = 
                    over (.,
                              col = "lifeExp" ,   
                              partition_by = "country" , 
                              order_by = "year" ,
                              preceding = -1:0 ,
                              fun = str_c ,
                              collapse = ",") ) %>% 
  unnest(over_col) # unnest col   #%>% view()

```
