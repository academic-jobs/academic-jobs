library(shiny)
library(dplyr)
library(ggvis)
#options(shiny.error = browser)

my_db <- src_mysql('academic', user="jobs_update", password="DataScienceAcc1516", host="127.0.0.1", port=1234)
unis_tbl <- tbl(my_db, 'university')
ref_tbl <- tbl(my_db, 'ref')
jobs_tbl <- tbl(my_db, 'jobs')
sub_tbl = tbl(my_db, 'subject')
sub_ref_tbl <- tbl(my_db, 'subject-ref') %>%
  select(ref_dept_id1, main_sub = main_sub_id)
# Join the jobs table with the subject-ref table using main_sub_id as the joining key.
jobs_sub_ref <- left_join(jobs_tbl, sub_ref_tbl, by = c('main_sub_id' = 'main_sub'))

shinyServer(function(input, output) {
  
  reactive( {
    
    norm_by_FTE = input$norm
    # Group by uni_id
    count_for_uni_by_subj = filter(jobs_sub_ref, ref_dept_id1 == input$ref_dept) %>%
                            group_by(uni_id) %>%
                            summarise(job_count=n()) %>%
                            select(uni_id, job_count)
    
    ref_by_subj_tmp <- filter(ref_tbl, ref_dept_id == input$ref_dept) %>%
                       group_by(uni_id) %>%
                       summarise(tot_FTE = sum(staffFTE), tot_4star=sum(fourstar), tot_3star=sum(threestar), tot_2star=sum(twostar), tot_1star=sum(onestar), tot_un=sum(unclassified))
                    
    if(norm_by_FTE){
      ref_by_subj_tmp2 <- mutate(ref_by_subj_tmp, score = ((tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))/tot_FTE)
    } else{
      ref_by_subj_tmp2 <- mutate(ref_by_subj_tmp, score = (tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))}
    
    ref_by_subj <- select(ref_by_subj_tmp2, uni_id, score)
    
    # Need to join the jobs and the uni data
    ref_by_job_count <- inner_join(count_for_uni_by_subj, ref_by_subj, by = c('uni_id' = 'uni_id')) %>%
      # Inner join gets rid of any rows where the university doesn't have a ref score and ref scores without job counts
      left_join(unis_tbl, by = c("uni_id" = "id"))
    
    #browser()
    
    # Standard R plotting in case interactive plotting doesn't work
    # plot(ref_by_job_count$score, ref_by_job_count$job_count)
    
    # Before we plot, check to see if there is no data...and if so then don't plot
    # and ideally give an message or a blank plot or some such jazz
    
    tooltip <- function(x) {
      return(x$uni_name)
    }
    
    # TODO: Add nice axis labels
    ref_by_job_count %>% collect() %>% ggvis(x = ~score, y = ~job_count, key := ~uni_name) %>%
      layer_points() %>%
      add_tooltip(tooltip, "hover") }) %>%
    bind_shiny("plot", "plot_ui")

  output$jobsDeptPlot <- renderPlot({
    count_for_uni_by_subj = filter(jobs_tbl, uni_id == input$uni) %>%
                            group_by(main_sub_id) %>%
                            summarise(count=n()) %>%
                            left_join(sub_tbl, by = c('main_sub_id' = 'id')) %>%
                            select(main_sub, count) %>%
                            collect()
    
    op <- par(mar = c(20,4,4,2) + 0.1)
    barplot(as.vector(count_for_uni_by_subj$count), names.arg = count_for_uni_by_subj$main_sub, las=2)
    
  }, height = 600, width = 'auto')
  
  reactive( {
    
    norm_by_FTE = input$norm_all
    # Group by uni_id
    count_for_uni = group_by(jobs_sub_ref, uni_id) %>%
                    summarise(job_count=n()) %>%
                    select(uni_id, job_count)
    
    ref_tmp <- group_by(ref_tbl, uni_id) %>%
      summarise(tot_FTE = sum(staffFTE), tot_4star=sum(fourstar), tot_3star=sum(threestar), tot_2star=sum(twostar), tot_1star=sum(onestar), tot_un=sum(unclassified))
    
    if(norm_by_FTE){
      ref_tmp2 <- mutate(ref_tmp, score = ((tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))/tot_FTE)
    } else{
      ref_tmp2 <- mutate(ref_tmp, score = (tot_4star*4 + tot_3star*3 + tot_2star*2 + tot_1star -tot_un)/(tot_4star+tot_3star+tot_2star+tot_1star+tot_un))}
    
    ref <- select(ref_tmp2, uni_id, score)
    
    # Need to join the jobs and the uni data
    ref_by_job_count <- inner_join(count_for_uni, ref, by = c('uni_id' = 'uni_id')) %>%
      # Inner join gets rid of any rows where the university doesn't have a ref score and ref scores without job counts
      left_join(unis_tbl, by = c("uni_id" = "id"))
    
    #browser()
    
    # Standard R plotting in case interactive plotting doesn't work
    # plot(ref_by_job_count$score, ref_by_job_count$job_count)
    
    # Before we plot, check to see if there is no data...and if so then don't plot
    # and ideally give an message or a blank plot or some such jazz
    
    tooltip <- function(x) {
      return(x$uni_name)
    }
    
    # TODO: Add nice axis labels
    ref_by_job_count %>% collect() %>% ggvis(x = ~score, y = ~job_count, key := ~uni_name) %>%
      layer_points() %>%
      add_tooltip(tooltip, "hover") }) %>%
    bind_shiny("plot_all", "plot_all_ui")
})
