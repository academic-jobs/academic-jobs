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

df_uni <- as.data.frame(unis_tbl)
new_df_uni <- setNames(as.list(df_uni$id), df_uni$uni_name)

shinyUI(fluidPage(
  
  # Application title
  headerPanel("REF data analysis against www.jobs.ac.uk"),
  
  tabsetPanel(
    tabPanel("REF vs job counts by subject",
             sidebarPanel(
               selectInput("ref_dept", "Department:", choices=new_df),
               checkboxInput("norm", "Normalise by FTE", value=FALSE),
               uiOutput('plot_ui')
             ),
             
             # Show a plot of the generated distributio
             mainPanel(
               ggvisOutput("plot")
             )),
    
    tabPanel("Jobs by department",
             sidebarPanel(
               selectInput("uni", "University:", 
                           choices=new_df_uni)
             ),
             
             # Show a plot of the generated distribution
             mainPanel(
               plotOutput("jobsDeptPlot")
             )),
    tabPanel("REF vs job counts All",
             sidebarPanel(
               checkboxInput("norm_all", "Normalise by FTE", value=FALSE),
               uiOutput('plot_all_ui')
             ),
             
             # Show a plot of the generated distributio
             mainPanel(
               ggvisOutput("plot_all")
             )),
    tabPanel("REF by subject",
             sidebarPanel(
               checkboxInput("norm_ref", "Normalise by FTE", value=FALSE),
               uiOutput('plot_ref_ui')
             ),
             
             # Show a plot of the generated distributio
             mainPanel(
               ggvisOutput("plot_ref")
  ))
)))