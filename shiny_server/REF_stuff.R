library(dplyr)
library(ggvis)
my_db <- src_mysql('academic', user="jobs_update", password="DataScienceAcc1516", host="127.0.0.1", port=1234)
unis_tbl <- tbl(my_db, 'university')
ref_tbl <- tbl(my_db, 'ref')
jobs_tbl <- tbl(my_db, 'jobs')
sub_ref_tbl <- tbl(my_db, 'subject-ref') %>%
               select(ref_dept_id1, main_sub = main_sub_id)
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

ref_by_subj <- select(ref_by_subj_tmp2, uni_id, score)

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