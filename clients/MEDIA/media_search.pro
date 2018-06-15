
function  media_search, DATES=dates_value,WAVES=waves_list,SERIES=series_name_value,CADENCE=cadence_list,NB_RES_MAX=nbresmax_value
	compile_opt idl2

	;#Define server
;;	sitools2_url='idoc-solar-portal-test.ias.u-psud.fr'
;;	sitools2_url='idoc-medoc-test.ias.u-psud.fr'
	sitools2_url='medoc-sdo.ias.u-psud.fr'

	IF n_elements(dates_value) EQ 0 THEN MESSAGE, "Provide dates please" ELSE DATES=dates_value
	IF n_elements(waves_list) EQ 0 THEN WAVES=LIST('94','131','171','193','211','304','335','1600','1700') ELSE WAVES=waves_list
	IF n_elements(series_name_value) EQ 0 THEN SERIES='aia.lev1' ELSE SERIES=series_name_value
	IF n_elements(cadence_list) EQ 0 THEN CADENCE=LIST('1 min') ELSE CADENCE=cadence_list
	IF n_elements(nbresmax_value) EQ 0 THEN NB_RES_MAX=-1 ELSE NB_RES_MAX=nbresmax_value
	allowed_serie=LIST('aia.lev1','hmi.sharp_720s','hmi.sharp_720s_nrt','hmi.m_720s','hmi.m_720s_nrt','hmi.sharp_cea_720s_nrt','hmi.ic_720s','hmi.ic_nolimbdark_720s_nrt')
	allowed_cadence_aia=HASH('12 sec', '12+sec', '12s', '12+sec','1 min', '1+min', '1m', '1+min','2 min', '2+min', '2m', '2+min', '10 min', '10+min', '10m', '10+min')
	allowed_cadence_aia+=HASH('30 min', '30+min', '30m', '30+min','1 h', '1+h', '1h', '1+h', '2 h', '2+h', '2h', '2+h')
	allowed_cadence_aia+=HASH('6 h', '6+h', '6h', '6+h','12 h', '12+h', '12h', '12+h', '1 day', '1+day', '1d', '1+day')
	allowed_12s_cadence=HASH('12 sec', '12+sec', '12s', '12+sec')
	allowed_cadence_hmi=HASH('12 min', '12+min', '1 h', '1+h', '2 h', '2+h', '6 h','6+h','12 h', '12+h','1 day', '1+day')
	allowed_cadence_hmi+=HASH('12m', '12+min', '1h','1+h','2h', '2+h','6h', '6+h', '12h', '12+h','1d', '1+day')
	allowed_waves=LIST('94','131','171','193','211','304','335','1600','1700','6173')

;#Control entries
	IF allowed_serie.WHERE(SERIES) EQ !NULL THEN MESSAGE, "Series should be in list : 'aia.lev1','hmi.sharp_720s','hmi.sharp_720s_nrt','hmi.m_720s','hmi.m_720s_nrt','hmi.sharp_cea_720s_nrt','hmi.ic_720s','hmi.ic_nolimbdark_720s_nrt'"
	IF TYPENAME(DATES) NE 'LIST' THEN MESSAGE, "DATES should be a list"
	IF TYPENAME(WAVES) EQ 'INT' THEN WAVES=LIST(STRCOMPRESS(WAVES, /REMOVE_ALL))
	IF TYPENAME(SERIES) NE 'STRING' THEN MESSAGE, "SERIES should be a string"
	IF  STRMID(SERIES,0,3) EQ 'hmi' THEN WAVES=['6173']
	IF TYPENAME(CADENCE) EQ 'STRING' THEN CADENCE=LIST(CADENCE)
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
	IF STRMID(SERIES,0,3) EQ 'aia' AND (allowed_cadence_aia.keys()).WHERE(CADENCE[0]) EQ !NULL THEN BEGIN
		MESSAGE, "Cadence should be in list '12 sec','1 min', '2 min', '10 min', '30 min', '1 h', '2 h', '6 h', '12 h', '1 day' or you can use shortcuts as '12s', '1m', '2h' or '1d'"
	ENDIF ELSE IF STRMID(SERIES,0,3) EQ 'hmi' AND (allowed_cadence_hmi.keys()).WHERE(CADENCE[0]) EQ !NULL THEN BEGIN
		MESSAGE, "Cadence should be in list '12 min', '1 h', '2 h', '6 h', '12 h', '1 day' or you can use shortcuts as '12m', '1h', '2h', '6h','12h' or '1d'"
	ENDIF
	FOREACH wave,WAVES DO BEGIN
		IF allowed_waves.WHERE(wave) EQ !NULL THEN MESSAGE, "Waves not allowed, it should be in list '94','131','171','193','211','304','335','1600','1700'"
	ENDFOREACH

;#Controls DATES Entries
	DATE_OPTIM=LIST()
	REGULAR_EXPR1=('^.{4}\-.{2}\-.{2}T.{2}:.{2}:.{2}')
	FOREACH timestamp_string, DATES DO BEGIN
;		PRINT, timestamp_string
		result_value= STREGEX(timestamp_string,REGULAR_EXPR1,/SUBEXPR, /EXTRACT)
		result= STREGEX(timestamp_string,REGULAR_EXPR1,/BOOLEAN)
		IF result THEN BEGIN
			DATE_OPTIM.Add, result_value+".000"
		ENDIF ELSE BEGIN
			MESSAGE, "Format for DATES should be YYYY-MM-DDTHH:MM:SS"
		ENDELSE
	ENDFOREACH
;	FOREACH date, DATE_OPTIM DO PRINT , date


;#Define Dataset uri
	dataset_uri=''
		IF STRMID(sitools2_url,0,9) EQ 'medoc-sdo' THEN BEGIN
		dataset_uri='/webs_IAS_SDO_dataset'
	ENDIF ELSE IF STRMID(sitools2_url,0,4) EQ 'idoc' AND STRMID(SERIES,0,3) EQ 'hmi' THEN BEGIN
		dataset_uri='/webs_IAS_SDO_HMI_dataset'
	ENDIF ELSE IF STRMID(sitools2_url,0,4) EQ 'idoc' AND STRMID(SERIES,0,3) EQ 'aia' THEN BEGIN
		dataset_uri='/webs_IAS_SDO_AIA_dataset'
	ENDIF

 	CATCH, Error_status
	IF (Error_status NE 0) THEN BEGIN
; Get the properties that will tell us more about the error.
;;		oUrl->GetProperty, RESPONSE_CODE=rspCode, RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
		PRINT , "media_search() fails, please retry later. Contact medoc-contact@ias.u-psud.fr if the problem persists."
		CATCH, /CANCEL
		MESSAGE, /REISSUE_LAST
	ENDIF ELSE BEGIN
		sdo_dataset=obj_new('sdoiasdataset',sitools2_url,dataset_uri )
		PRINT, "Loading MEDIA Sitools2 client : ",sdo_dataset->get_sitools2_url()
		fields_list=(sdo_dataset->get_attributes()).FIELDS_LIST
		IF n_elements(fields_list) EQ 0 THEN MESSAGE, "sdo_dataset->get_attributes() has return 0 elements."
;;		PRINT , "Nbr elements :", n_elements(fields_list)
;;		PRINT, "fields_list : ", fields_list
;;		FOREACH field, fields_list DO PRINT, field->get_name()
		fields_struct=sdo_dataset->get_fields_struct()
;;		PRINT, fields_struct
;;		PRINT, "fields_struct['date__obs'] : ", fields_struct['date__obs']
		;dates_param=LIST([fields_list[4]],DATES,'DATE_BETWEEN')
		dates_param=LIST([fields_struct['date__obs']],DATE_OPTIM,'DATE_BETWEEN')
;;		PRINT ,"Date_param : ", dates_param
;		waves_param=LIST([fields_list[5]],WAVES,'IN')
		waves_param=LIST([fields_struct['wavelnth']],WAVES,'IN')
;		PRINT , "Waves param : ", waves_param
		SERIES_LIST=LIST(SERIES)
		serie_param=LIST([fields_struct['series_name']],SERIES_LIST,'IN')
;		PRINT, "Series param : ", serie_param
	;	PRINT , "Cadence : " , CADENCE , "allowed_cadence_aia['1 min '] : ",allowed_cadence_aia['1 min']
;		cadence_param=LIST([fields_list[10]],allowed_cadence_aia[CADENCE[0]],'CADENCE')
		IF STRMID(SERIES,0,3) EQ 'aia' THEN BEGIN
			cadence_param=LIST([fields_struct['mask_cadence']],allowed_cadence_aia[CADENCE[0]],'CADENCE')
		ENDIF ELSE IF STRMID(SERIES,0,3) EQ 'hmi' THEN BEGIN
			cadence_param=LIST([fields_struct['mask_cadence']],allowed_cadence_hmi[CADENCE[0]],'CADENCE')
		ENDIF
;		PRINT, "Cadence param : ", cadence_param

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
;;			PRINT, Q1
;;			PRINT, Q1->get_value_list_str()

			Q2=obj_new('query',waves_param)
;;			PRINT, Q2
;;			PRINT, Q2->get_value_list_str()

			Q3=obj_new('query',cadence_param)
;;			PRINT, Q3
;;			PRINT, Q3->get_value_list_str()

			Q4=obj_new('query',serie_param)
;;			PRINT, Q4
;;			PRINT, Q4->get_value_list_str()

;;			IF (allowed_12s_cadence.keys()).WHERE(CADENCE[0]) NE !NULL THEN query_list=LIST(Q1,Q2) ELSE query_list=LIST(Q1,Q2,Q3)
			IF (allowed_12s_cadence.keys()).WHERE(CADENCE[0]) NE !NULL THEN query_list=LIST(Q1,Q2,Q4) ELSE query_list=LIST(Q1,Q2,Q3,Q4)
;			HELP, query_list
;			PRINT , "query 1 : ", query_list[0]
;			PRINT , "query 2 : ",query_list[1]
;			PRINT , "query 3 : ",query_list[2]
;			PRINT , "query 4 : ",query_list[3]
;			FOREACH query, query_list DO PRINT, "Query attributes : ",query->get_attributes()

			;;Ask columns : get, recnum, sunum, date__obs, wavelnth, ias_location,exptime,t_rec_index etc...
			;;output_options=LIST(fields_list[0],fields_list[1],fields_list[2],fields_list[4],fields_list[5],fields_list[7],fields_list[8],fields_list[9])
		ENDELSE

		IF STRMID(sitools2_url,0,4) EQ 'idoc' AND STRMID(SERIES,0,3) EQ 'aia' THEN BEGIN
			output_options=LIST(fields_struct['get'],fields_struct['recnum'],fields_struct['sunum'],fields_struct['date__obs'],fields_struct['series_name'],$
			fields_struct['wavelnth'],fields_struct['ias_location'],fields_struct['exptime'],fields_struct['t_rec_index'])
		ENDIF ELSE IF STRMID(sitools2_url,0,4) EQ 'idoc' AND STRMID(SERIES,0,9) EQ 'hmi.sharp' THEN BEGIN
			output_options=LIST(fields_struct['recnum'],fields_struct['sunum'],fields_struct['date__obs'],fields_struct['series_name'],$
			fields_struct['wavelnth'],fields_struct['ias_location'],fields_struct['exptime'],fields_struct['t_rec_index'],fields_struct['ias_path'],fields_struct['harpnum'] )
		ENDIF ELSE IF STRMID(sitools2_url,0,4) EQ 'idoc' AND STRMID(SERIES,0,3) EQ 'hmi' THEN BEGIN
			output_options=LIST(fields_struct['recnum'],fields_struct['sunum'],fields_struct['date__obs'],fields_struct['series_name'],$
			fields_struct['wavelnth'],fields_struct['ias_location'],fields_struct['exptime'],fields_struct['t_rec_index'],fields_struct['ias_path'])
		ENDIF ELSE IF sitools2_url EQ 'medoc-sdo.ias.u-psud.fr' AND STRMID(SERIES,0,3) EQ 'aia' THEN BEGIN
			output_options=LIST(fields_struct['get'],fields_struct['recnum'],fields_struct['sunum'],fields_struct['date__obs'],fields_struct['series_name'],$
			fields_struct['wavelnth'],fields_struct['ias_location'],fields_struct['exptime'],fields_struct['t_rec_index'])
		ENDIF ELSE BEGIN
			PRINT , "Output not defined"
		ENDELSE
		;PRINT ,"get :", fields_struct['get']
;		PRINT , "recnum :", fields_struct['recnum']
;		PRINT , "sunum :", fields_struct['sunum']
;		PRINT , "date__obs :", fields_struct['date__obs']
;		PRINT , "series_name :", fields_struct['series_name']
;		PRINT , "date__obs :", fields_struct['date__obs']
;		PRINT , "wavelnth :", fields_struct['wavelnth']
;		PRINT , "ias_location :", fields_struct['ias_location']
;		PRINT , "exptime :", fields_struct['exptime']
;		PRINT , "t_rec_index :", fields_struct['t_rec_index']

;		FOREACH output, output_options DO PRINT, "output option name  : ",output->get_name()
		;;sort date_obs ASC, wave ASC
;;		sort_options=LIST(LIST(fields_list[5],'ASC'),LIST(fields_list[4],'ASC'))
		sort_options=LIST(LIST(fields_struct['date__obs'],'ASC'),LIST(fields_struct['wavelnth'],'ASC'))
;		FOREACH sort_item, sort_options DO PRINT, "sort_options name : ",sort_item[0]->get_name()

		;; Error hanlder def
		CATCH, Error_status
	 	IF Error_status NE 0 THEN BEGIN
			PRINT, "media_search() fails performing sdo_dataset_search(), please retry later. Contact medoc-contact@ias.u-psud.fr if the problem persists."
			CATCH, /CANCEL
			CATCH, Error_status
		ENDIF ELSE BEGIN
			results=sdo_dataset->search(query_list, output_options, sort_options, limit_to_nb_res_max=NB_RES_MAX)
;			FOREACH data, results DO PRINT, JSON_SERIALIZE(data)
			sdo_data_list=LIST()

			IF n_elements(results) NE 0 THEN BEGIN
				;; Error hanlder def
				CATCH, Error_status
				IF (Error_status NE 0) THEN BEGIN
					PRINT , "media_search() failed performing creation of sdoData object, contact medoc-contact@ias.u-psud.fr to get some help."
					CATCH, /CANCEL
				ENDIF ELSE BEGIN
					FOREACH data_item, results DO BEGIN
;;						PRINT, JSON_SERIALIZE(data_item)
						sdo_data_list.Add, obj_new('sdoData',data_item)
						;;PRINT , "Done "
					ENDFOREACH
				ENDELSE
			ENDIF
			PRINT , "Nbr results : "+STRTRIM(n_elements(results),2)

			OBJ_DESTROY, Q1,Q2,Q3,Q4
			return, sdo_data_list
		ENDELSE
	ENDELSE
end
