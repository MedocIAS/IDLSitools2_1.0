
function gaia_search, DATES=dates_value, NB_RES_MAX=nbresmax_value
	compile_opt idl2
	
	IF n_elements(dates_value) EQ 0 THEN message, "Provide dates please" ELSE DATES=dates_value
	IF n_elements(nbresmax_value) EQ 0 THEN NB_RES_MAX=-1 ELSE NB_RES_MAX=nbresmax_value

	gaia_dataset=obj_new('gaiadataset')

	PRINT, "Loading GAIA-DEM Sitools2 client : ",gaia_dataset->get_sitools2_url()
	fields_list=(gaia_dataset->get_attributes()).FIELDS_LIST
;;	PRINT fields_list
	dates_param=LIST([fields_list[1]],DATES,'DATE_BETWEEN')
	

	Q1=obj_new('query',dates_param)

	query_list=LIST(Q1)
	;;Ask columns : download, date_obs, sunum_193, filename, temp_fits_rice, em_fits_rice, width_fits_rice, chi2_fits_rice 
	output_options=LIST(fields_list[0],fields_list[1],fields_list[5],fields_list[8],fields_list[18],fields_list[19],fields_list[20],fields_list[21])
	;;sort date_obs ASC
	sort_options=LIST(LIST(fields_list[1],'ASC'))

	results=gaia_dataset->search(query_list, output_options, sort_options, limit_to_nb_res_max=NB_RES_MAX)
	
;;	FOREACH data, results DO PRINT, JSON_SERIALIZE(data)
	gaia_data_list=LIST()
	IF n_elements(results) NE 0 THEN BEGIN
		FOREACH data_item, results DO BEGIN
			gaia_data_list.Add, obj_new('gaiadata',data_item)
		ENDFOREACH
	ENDIF
	PRINT , "Nbr results : "+STRTRIM(n_elements(results),2)

	OBJ_DESTROY, Q1
	return, gaia_data_list
end
