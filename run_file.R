# runfile

library(tidyverse)
library(NHSRdatasets)

# bring in some data for a couple of sites
dat <- ae_attendances |> 
  filter(org_code %in% c('RF4', 'R1H'),
         type == 'other')

# make a quick function that will draw a plot for site and 
# variable selected

plot_site <- function(data, site, variable) {
  data <- data |>
    filter(org_code ==site)
  
  data |>
    ggplot(aes(x=period, y=!!sym(variable))) +
    geom_line() + 
    ggtitle(paste0(str_to_sentence(variable), 
                   ' plot for site: ', 
                   site))
}

# a couple of test plots to check function works
plot_site(dat, 'RF4', 'attendances')

plot_site(dat, 'R1H', 'breaches')

# now we need to make a vector of sites to run through
sites_vector <- unique(dat$org_code)

# now we can set up the loop and trigger the markdown file

for (i in sites_vector) {
  params <- list(
    org_code = i)
  
  rmarkdown::render(paste0("output_simple.rmd"),
                    output_file = paste0("report_simple_", i, ".html"),
                    params = params,
                    envir = new.env())
}


#################
  
# now lets do the optional turning on and off thing
# this version will be a self contained dataframe but it could
# easily be an external csv or something else

sites <- as.character(sites_vector)
att <- c(TRUE, FALSE)
brea <- c(TRUE, TRUE)

df <-  data.frame(sites, att, brea)

# this now gives us a mini data frame with a list of the sites, the 
# variables with a true or false as to include them in the report or not


for (i in sites_vector) {
  params <- list(
    org_code = i,
    plot_attend = df$att[df$sites == i],
    plot_brea = df$brea[df$sites == i])
  
  rmarkdown::render(paste0("output_complex.rmd"),
                    output_file = paste0("report_complex_", i, ".html"),
                    params = params,
                    envir = new.env())
}








