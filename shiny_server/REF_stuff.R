library(dplyr)
library(ggvis)
my_db <- src_mysql('academic', user="jobs_update", password="DataScienceAcc1516", host="127.0.0.1", port=1234)
unis_tbl <- tbl(my_db, 'university')
ref_tbl <- tbl(my_db, 'ref')
jobs_tbl <- tbl(my_db, 'jobs')
sub_ref_tbl <- tbl(my_db, 'subject-ref') %>%
               select(ref_dept_id1, main_sub = main_sub_id)
ref_dept_tbl <- tbl(my_db, 'ref_dept')
norm_by_FTE <- FALSE

# Join the jobs table with the subject-ref table using main_sub_id as the joining key.
# Does not work without copy=TRUE.
jobs_sub_ref <- left_join(jobs_tbl, sub_ref_tbl, by = c('main_sub_id' = 'main_sub'))

# Group by uni_id

count_for_uni_by_subj = # filter(job_sub_ref, ref_dept_id == 3) %>%
                        group_by(jobs_sub_ref, uni_id) %>%
                        summarise(job_count=n()) %>%
                        select(uni_id, job_count)

#filter(ref_tbl, ref_dept_id == 3) %>%
ref_by_subj_tmp <- group_by(ref_tbl, uni_id) %>%
                   summarise(tot_FTE = sum(staffFTE), tot_4star=sum(fourstar), tot_3star=sum(threestar), tot_2star=sum(twostar), tot_1star=sum(onestar), tot_un=sum(unclassified))

if(norm_by_FTE){
  ref_by_subj_tmp2 <- mutate(ref_by_subj_tmp, score = ((tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))/tot_FTE)
  } else{
      ref_by_subj_tmp2 <- mutate(ref_by_subj_tmp, score = (tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))}

# Need to join the jobs and the uni data
ref_by_job_count <- inner_join(count_for_uni_by_subj, ref_by_subj, by = c('uni_id' = 'uni_id')) %>%
                    # Inner join gets rid of any rows where the university doesn't have a ref score and ref scores without job counts
                    left_join(unis_tbl, by = c("uni_id" = "id")) %>%
                    collect()

all_values <- function(x) {
  if(is.null(x)) return(NULL)
  row <- ref_by_job_count[ref_by_job_count$uni_id == x$uni_id, ]
  paste0(names(row), ": ", format(row), collapse = "<br />")
}

tooltip <- function(x) {
  if(is.null(x)) return(NULL)
  
  row <- ref_by_job_count[ref_by_job_count$uni_id == x$uni_id, ]
  
  return(row$uni_name)
}

ref_by_job_count %>% ggvis(x = ~score, y = ~job_count, key := ~uni_id) %>%
  layer_points() %>%
  add_tooltip(tooltip, "hover")

##################################################################################################
ref_for_subj_tmp = group_by(ref_tbl, ref_dept_id) %>%
  summarise(tot_FTE=sum(staffFTE), tot_4star=sum(fourstar), tot_3star=sum(threestar), tot_2star=sum(twostar), tot_1star=sum(onestar), tot_un=sum(unclassified))

if(norm_by_FTE){
  ref_for_subj_tmp2 <- mutate(ref_for_subj_tmp, score = ((tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))/tot_FTE)
} else{
  ref_for_subj_tmp2 <- mutate(ref_for_subj_tmp, score = (tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))}

ref_for_subj <- select(ref_for_subj_tmp2, ref_dept_id, score) %>% 
                left_join(ref_dept_tbl, by = c("ref_dept_id" = "id")) %>%           
                collect()

tooltip2 <- function(x) {
  return(x$ref_dept_name)
}

ref_for_subj %>% ggvis(x = ~ref_dept_id, y = ~score, key := ~ref_dept_name) %>%
  layer_points() %>%
  add_tooltip(tooltip2, "hover")

##################################################################################################

library(shiny)
library(dplyr)


Sys.setlocale('LC_ALL','C') 

# Get unis list, and convert to 'dict-style' list from uni name (key)
# to id (value)
my_db <- src_mysql('academic', user="jobs_update", password="DataScienceAcc1516", host="127.0.0.1", port=1234)
unis <- tbl(my_db, 'university')
df <- as.data.frame(unis)
new_df <- setNames(as.list(df$id), df$uni_name)

shinyUI(fluidPage(
  # Application title
  headerPanel("Test Multiple Pages"),
  
  tabsetPanel(
    tabPanel("Jobs by department",
             sidebarPanel(
               selectInput("uni", "University:", 
                           choices=new_df)
             ),
             
             # Show a plot of the generated distributio
             mainPanel(
               plotOutput("distPlot")
             )),
    
    tabPanel("New cool thing",
             # Define the sidebar with one input
             sidebarPanel(
               selectInput("region", "Region:", 
                           choices=colnames(WorldPhones)),
               hr(),
               helpText("Data from AT&T (1961) The World's Telephones.")
             ),
             
             # Create a spot for the barplot
             mainPanel(
               plotOutput("phonePlot")  
             ))
    
    
  )))






