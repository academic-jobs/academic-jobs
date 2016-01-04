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

ref_dept_id = c(1,2,3,4,5,7,8,9,10,11,12,13,15,16,22,24,26,27,35)
ref_dept_name = c("Allied Health Professions Dentistry Nursing and Pharmacy",
                  "Psychology Psychiatry and Neuroscience",
                  "Biological Sciences",
                  "General Engineering",
                  "Architecture Built Environment and Planning",
                  "Business and Management Studies",
                  "Law",
                  "Social Work and Social Policy",
                  "Education",
                  "English Language and Literature",
                  "History",
                  "Art and Design: History Practice and Theory",
                  "Communication Cultural and Media Studies Library and Information Management",
                  "Computer Science and Informatics",
                  "Mathematical Sciences",
                  "Sport and Exercise Sciences Leisure and Tourism",
                  "Economics and Econometrics",
                  "Politics and International Studies",
                  "Agriculture Veterinary and Food Science")

df <- data.frame(ref_dept_id, ref_dept_name)

df <- arrange(df, ref_dept_name) %>%
      as.data.frame()
new_df <- setNames(as.list(df$ref_dept_id), df$ref_dept_name)

df_uni <- as.data.frame(unis_tbl) %>%
          arrange(uni_name)
new_df_uni <- setNames(as.list(df_uni$id), df_uni$uni_name)

shinyUI(fluidPage(
  
  # Application title
  headerPanel("REF data analysis against www.jobs.ac.uk"),
  
  tabsetPanel(
    tabPanel("REF vs job counts by subject",
             sidebarPanel(
               selectInput("ref_dept", "Unit of Assessment:", choices=new_df),
               checkboxInput("norm", "Normalise by FTE", value=FALSE),
               uiOutput('plot_ui')
             ),
             
             # Show a plot of the generated distributio
             mainPanel(
               ggvisOutput("plot")
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
    
    tabPanel("Jobs by department",
             sidebarPanel(
               selectInput("uni", "University:", 
                           choices=new_df_uni)
             ),
             
             # Show a plot of the generated distribution
             mainPanel(
               plotOutput("jobsDeptPlot")
             )),
    tabPanel("REF by subject",
             sidebarPanel(
               checkboxInput("norm_ref", "Normalise by FTE", value=FALSE),
               uiOutput('plot_ref_ui')
             ),
             
             # Show a plot of the generated distributio
             mainPanel(
               ggvisOutput("plot_ref")
             )
    )
  )
)
)