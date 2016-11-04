
function  metadata_search, KEYWORDS=keywords_list, RECNUM_LIST=recnum_list, SERIE=serie_name, SERVER_NAME=server_name
	compile_opt idl2
	
	IF n_elements(keywords_list) EQ 0 THEN message," Error metadata_search(): keywords must be specified" ELSE KEYWORDS=keywords_list
	IF n_elements(recnum_list) EQ 0 THEN  MESSAGE, "RECNUM_LIST param should be provided" ELSE RECNUM_LIST=recnum_list
	IF n_elements(serie_name) EQ 0 THEN serie_name='aia.lev1'
	IF n_elements(server_name) EQ 0 THEN server_name='medoc-sdo.ias.u-psud.fr'
	;PRINT , N_ELEMENTS(RECNUM_LIST)

	dataset_uri=''
	IF STRMID(SERVER_NAME,0,9) EQ 'medoc-sdo' THEN BEGIN 
		dataset_uri="webs_aia_dataset"
	ENDIF ELSE IF STRMID(server_name,0,10) EQ 'idoc-solar' AND serie_name EQ "aia.lev1" THEN BEGIN
		dataset_uri="webs_aia_dataset"
	ENDIF ELSE IF STRMID(server_name,0,10) EQ 'idoc-solar' AND STRMID(serie_name,0,3) EQ "hmi" THEN BEGIN
		dataset_uri="webs_"+serie_name+"_dataset"
		;dataset_uri=serie_name
	ENDIF 
	;PRINT , "SERVER_NAME : ", server_name
	;PRINT , "dataset_uri : ", dataset_uri

	ds_aia_lev1=obj_new('sdoaiadataset', SERVER_NAME, dataset_uri)
	;#Build Query
;	fields_list=(ds_aia_lev1->get_attributes()).FIELDS_LIST
	fields_struct=ds_aia_lev1->get_fields_struct()

;	param_query_aia=LIST(fields_list[0],RECNUM_LIST,'IN')
	param_query_aia=LIST(fields_struct['recnum'],recnum_list,'IN')

	;PRINT ,"param_query_aia", param_query_aia
	Q_aia=obj_new('query',param_query_aia)
	;PRINT, "query : ", Q_aia
	O1_aia=LIST()
	FOREACH key, KEYWORDS DO BEGIN
		IF (ds_aia_lev1->get_fields_struct()).HasKey(key) THEN O1_aia.Add,(ds_aia_lev1->get_fields_struct())[key] ELSE message,"Error metadata_search(): keyword does not exist" 
	ENDFOREACH

	S1_aia=LIST(LIST(fields_struct['date__obs'],'ASC'));;sort by date_obs ascendant

	results=ds_aia_lev1->search(LIST(Q_aia),O1_aia,S1_aia)
	OBJ_DESTROY, ds_aia_lev1, Q_aia 
	PRINT , "Nbr results : "+STRTRIM(n_elements(results),2)
	IF n_elements(results) EQ 1 THEN return, results[0] ELSE return , results
end
