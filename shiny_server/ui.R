library(shiny)
library(dplyr)
library(ggvis)

Sys.setlocale('LC_ALL','C') 

# Get unis list, and convert to 'dict-style' list from uni name (key)
# to id (value)
my_db <- src_mysql('academic', user="jobs_update", password="DataScienceAcc1516", host="127.0.0.1", port=1234)
unis_tbl <- tbl(my_db, 'university')
ref_tbl <- tbl(my_db, 'ref')
jobs_tbl <- tbl(my_db, 'jobs')
ref_dept_tbl <- tbl(my_db,'ref_dept')
sub_ref_tbl <- tbl(my_db, 'subject-ref') %>%
  select(ref_dept_id1, main_sub = main_sub_id)

df <- arrange(ref_dept_tbl, ref_dept_name) %>%
      as.data.frame(ref_dept_tbl)
new_df <- setNames(as.list(df$id), df$ref_dept_name)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Ref Score relationship with job count"),
  
  sidebarPanel(
    selectInput("ref_dept", "Department:", 
                choices=new_df),
    checkboxInput("norm", "Normalise by FTE", value=FALSE),
    uiOutput('plot_ui')
  ),
  
  # Show a plot of the generated distributio
  mainPanel(
    ggvisOutput("plot")
  )
))
