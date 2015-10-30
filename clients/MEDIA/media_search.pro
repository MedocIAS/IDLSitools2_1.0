
function  media_search, DATES=dates_value,WAVES=waves_list,CADENCE=cadence_list,NB_RES_MAX=nbresmax_value
	compile_opt idl2
	
	IF n_elements(dates_value) EQ 0 THEN message, "Provide dates please" ELSE DATES=dates_value
	IF n_elements(waves_list) EQ 0 THEN WAVES=LIST('94','131','171','193','211','304','335','1600','1700') ELSE WAVES=waves_list
	IF n_elements(cadence_list) EQ 0 THEN CADENCE=LIST('1 min') ELSE CADENCE=cadence_list
	IF n_elements(nbresmax_value) EQ 0 THEN NB_RES_MAX=-1 ELSE NB_RES_MAX=nbresmax_value
	allowed_cadence=HASH('12 sec', '12+sec', '12s', '12+sec','1 min', '1+min', '1m', '1+min','2 min', '2+min', '2m', '2+min', '10 min', '10+min', '10m', '10+min')
	allowed_cadence+=HASH('30 min', '30+min', '30m', '30+min','1 h', '1+h', '1h', '1+h', '2 h', '2+h', '2h', '2+h')
	allowed_cadence+=HASH('6 h', '6+h', '6h', '6+h','12 h', '12+h', '12h', '12+h', '1 day', '1+day', '1d', '1+day')
	allowed_12s_cadence=HASH('12 sec', '12+sec', '12s', '12+sec')
	allowed_waves=LIST('94','131','171','193','211','304','335','1600','1700')
	IF TYPENAME(CADENCE) EQ 'STRING' THEN CADENCE=LIST(CADENCE)
	IF TYPENAME(WAVES) EQ 'INT' THEN WAVES=LIST(STRCOMPRESS(WAVES, /REMOVE_ALL))
	WAVES_STRING=LIST()
	IF TYPENAME(WAVES) EQ 'LIST' THEN BEGIN 
		FOREACH wave, WAVES DO BEGIN
			IF TYPENAME(wave) EQ 'INT' THEN BEGIN
				WAVES_STRING.ADD, STRCOMPRESS(wave, /REMOVE_ALL),WAVES.WHERE(wave)
			ENDIF ELSE BEGIN 
				WAVES_STRING.ADD,wave
			ENDELSE
		ENDFOREACH
		WAVES=WAVES_STRING
	ENDIF
	IF (allowed_cadence.keys()).WHERE(CADENCE[0]) EQ !NULL THEN message, "Cadence should be in list '12 sec','1 min', '2 min', '10 min ', '30 min', '1 h', '2 h', '6 h', '12 h', '1 day' or you can use shortcuts as '12s', '1m', '2h' or '1d'"
	FOREACH wave,WAVES DO BEGIN 
		IF allowed_waves.WHERE(wave) EQ !NULL THEN message, "Waves not allowed, it should be in list '94','131','171','193','211','304','335','1600','1700'"
	ENDFOREACH

	
 	CATCH, Error_status
	IF (Error_status NE 0) THEN BEGIN
; Get the properties that will tell us more about the error.
;;		oUrl->GetProperty, RESPONSE_CODE=rspCode, RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
		PRINT , "media_search() fails creating sdo_dataset object, please retry later. Contact medoc-contact@ias.u-psud.fr if the problem persists."
		CATCH, /CANCEL
;;		MESSAGE, /REISSUE_LAST
	ENDIF ELSE BEGIN
		sdo_dataset=obj_new('sdoIasDataset')
		PRINT, "Loading MEDIA Sitools2 client : ",sdo_dataset->get_sitools2_url()
		fields_list=(sdo_dataset->get_attributes()).FIELDS_LIST
;;		FOREACH field, fields_list DO PRINT, field->get_name()
		dates_param=LIST([fields_list[4]],DATES,'DATE_BETWEEN')
		waves_param=LIST([fields_list[5]],WAVES,'IN')
	;;	PRINT , "Cadence : " , CADENCE , "allowed_cadence['1 min '] : ",allowed_cadence['1 min']
		cadence_param=LIST([fields_list[10]],allowed_cadence[CADENCE[0]],'CADENCE')
		query_list=LIST()

		CATCH, Error_status
		IF (Error_status NE 0) THEN BEGIN
;; Get the properties that will tell us more about the error.
;;			oUrl->GetProperty, RESPONSE_CODE=rspCode, RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
			PRINT , "media_search() fails creating query object, please retry later. Contact medoc-contact@ias.u-psud.fr if the problem persists."
			CATCH, /CANCEL
;;			MESSAGE, /REISSUE_LAST
		ENDIF ELSE BEGIN
			Q1=obj_new('query',dates_param)
			Q2=obj_new('query',waves_param)
			Q3=obj_new('query',cadence_param)
	
			;;PRINT, Q3
			;;PRINT, Q3->get_value_list_str()
			IF (allowed_12s_cadence.keys()).WHERE(CADENCE[0]) NE !NULL THEN query_list=LIST(Q1,Q2) ELSE query_list=LIST(Q1,Q2,Q3)

			;;HELP, query_list
			;;PRINT , query_list[0]
			;;FOREACH query, query_list DO PRINT, query->get_attributes()
	
			;;Ask columns : get, recnum, sunum, date__obs, wavelnth, ias_location,exptime,t_rec_index etc...
			output_options=LIST(fields_list[0],fields_list[1],fields_list[2],fields_list[4],fields_list[5],fields_list[7],fields_list[8],fields_list[9])
			;;sort date_obs ASC, wave ASC
			sort_options=LIST(LIST(fields_list[5],'ASC'),LIST(fields_list[4],'ASC'))
		ENDELSE

		;; Error hanlder def
		CATCH, Error_status
	 	IF Error_status NE 0 THEN BEGIN
			PRINT, "media_search() fails performing sdo_dataset_search, please retry later. Contact medoc-contact@ias.u-psud.fr if the problem persists."
			CATCH, /CANCEL
			CATCH, Error_status
			IF (Error_status NE 0) THEN BEGIN
				PRINT , "media_search() failed twice, contact medoc-contact@ias.u-psud.fr to get some help."
				CATCH, /CANCEL
			ENDIF ELSE BEGIN
				results=sdo_dataset->search(query_list, output_options, sort_options, limit_to_nb_res_max=NB_RES_MAX)
			ENDELSE
		ENDIF ELSE BEGIN
			results=sdo_dataset->search(query_list, output_options, sort_options, limit_to_nb_res_max=NB_RES_MAX)
;;			FOREACH data, results DO PRINT, JSON_SERIALIZE(data)
			sdo_data_list=LIST()
			IF n_elements(results) NE 0 THEN BEGIN
				FOREACH data_item, results DO BEGIN
					;;PRINT, JSON_SERIALIZE(data_item)
					sdo_data_list.Add, obj_new('sdoData',data_item)
					;;PRINT , "Done "
				ENDFOREACH
			ENDIF
			PRINT , "Nbr results : "+STRTRIM(n_elements(results),2)
	
			OBJ_DESTROY, Q1,Q2,Q3
			return, sdo_data_list
		ENDELSE
	ENDELSE
end
