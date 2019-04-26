# Pakiety ######################################################################
library(rvest)
library(dplyr)
library(tidyr)
library(magrittr)

# Parametry ####################################################################
website_path <- "https://stat.gov.pl/obszary-tematyczne/rynek-pracy/bezrobocie-rejestrowane/stopa-bezrobocia-rejestrowanego-w-latach-1990-2019,4,1.html"

output_path <- "dane/"
output_name <- "bezrobocie"

save_rds <- TRUE
save_csv <- FALSE

# Możliwe "a"/"b" - ważne dla roku 2002
data_option <- "b"

# Kod ##########################################################################
data_extract <- read_html(website_path) %>%
    html_table() %>%
    magrittr::extract2(1)

clear_regex <- switch(data_option,
                      "b" = "[[:print:]]+[[:cntrl:]]+|\\*",
                      "a" = "[[:cntrl:]]+[[:print:]]+|\\*")

unemployment <- data_extract %>%
    tidyr::gather("Miesiąc", "Wartość", -`rok/miesiąc`) %>%
    mutate(
        Wartość = gsub(clear_regex, "", Wartość),
        Wartość = gsub(",", ".", Wartość),
        Wartość = as.numeric(Wartość)) %>%
    rename(Rok = `rok/miesiąc`) %>%
    mutate(
        Rok = as.integer(substr(Rok, 1, 4)),
        MiesiącInt = match(Miesiąc, unique(Miesiąc))) %>%
    arrange(Rok, MiesiącInt)

# Zapisywanie
if (save_csv) {
    write.csv2(unemployment,
               paste0(output_path, output_name,
                      "_", data_option, ".csv"),
               row.names = FALSE)
}
if (save_rds) {
    saveRDS(unemployment,
            paste0(output_path, output_name,
                   "_", data_option, ".rds"))
}
