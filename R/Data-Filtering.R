###
# Clean up data sets to have minimal sets for presentation
# Zane
# 2024-04-14
###

# HAI data set
hai_raw <- readr::read_rds(here::here("data/pres-data.Rds"))

hai_clean <-
	hai_raw |>
	dplyr::filter(
		outcome == "postvactiter",
		method == "cart_2d_post"
	) |>
	dplyr::rename(
		pretiter = prevactiter,
		posttiter = y
	) |>
	dplyr::select(-method, -vaccine_type, -vaccine_fullname, -strain_type,
								-outcome, -id) |>
	# Create a new ID variable for stan
	dplyr::mutate(
		study = stringr::str_extract(uniq_id, "^([a-z]*)"),
		id = as.integer(as.factor(uniq_id))
	)

readr::write_rds(
	hai_clean,
	here::here("data", "hai-clean.Rds")
)

# NoV data set
nov_raw <- readr::read_rds(here::here("data/dat_biv_fin.rds"))

nov_clean <-
	nov_raw |>
	dplyr::select(
		treatment = trttrue,
		protected = infect_protect,
		gii_pgm
	) |>
	# Recode the treatment as 1/2
	dplyr::mutate(
		treatment =  ifelse(treatment == "Vaccine", 1, 0)
	)

readr::write_rds(
	nov_clean,
	here::here("data", "nov-clean.Rds")
)
