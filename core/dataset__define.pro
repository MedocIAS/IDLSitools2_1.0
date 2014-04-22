
function dataset::init,url
	compile_opt idl2

	self.name=''
	self.description=''
	self.uri=''
	self.url=''
	self.fields_list=LIST()
	self.fields_struct=HASH()
	self.filter_list=LIST()
	self.allowed_filter_list=LIST()
	self.sort_list=LIST()
	self.allowed_sort_list=LIST()
	self.no_Client_Access_list=LIST()
	self.resources_list=LIST()
	self.primary_key=OBJ_NEW()

	self->compute_attributes,url
	self->resources_list
	return,1
end

pro dataset::compute_attributes,url
	compile_opt idl2
	
	self.uri="/"+(strsplit(url,"/",/EXTRACT))[-1]
	service=(strsplit(url,"/",/EXTRACT))[0]
	self.url=url
	str_url=self.url+'?media=json'
	oUrl=OBJ_NEW('IDLnetUrl')
	oUrl.SetProperty, url_scheme='http'
	oUrl.SetProperty, URL_HOST=str_url
; If the url object throws an error it will be caught here
; Get the properties that will tell us more about the error.
;	oUrl->GetProperty, RESPONSE_CODE=rspCode, RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
;	PRINT ,"rspCode : ",rspCode
;	PRINT ,"rspHdr : ",rspHdr
   	CATCH, Error_status
;;	PRINT , "Error_status : ", Error_status
	IF (Error_status NE 0) THEN BEGIN
		PRINT , "dataset::compute_attributes() fails, dataset service at ",service," is not available."
		OBJ_DESTROY, oUrl
		CATCH, /CANCEL
		MESSAGE, /REISSUE_LAST
	ENDIF ELSE BEGIN
		json = oUrl.Get(/STRING_ARRAY)
		json_result=JSON_PARSE(STRJOIN(json))
		result=json_result['dataset']
	;;	PRINT, JSON_SERIALIZE(result)
		self.name=result['name']
		self.description=result['description']
		self.status=result['status']
		columns=result['columnModel']
	;;	PRINT, JSON_SERIALIZE(columns)
		FOR i=0, n_elements(columns)-1 DO BEGIN 
			IF  TYPENAME(columns[i])  eq 'HASH' THEN BEGIN
				key= (columns[i])['columnAlias']
	;;			PRINT, key
				field=obj_new('field',columns[i])
	;;			PRINT, field
				self.fields_list.Add,field
				self.fields_struct+=HASH(key,field)
				IF columns[i].haskey('filter') THEN BEGIN 
				IF (columns[i])['filter'] THEN self.filter_list.Add,field 
				ENDIF
				IF columns[i].haskey('sortable') THEN BEGIN 
					IF (columns[i])['sortable'] THEN self.sort_list.Add,field 
				ENDIF
				IF columns[i].haskey('primaryKey') THEN BEGIN 
					IF (columns[i])['primaryKey'] THEN self.primary_key=field 
				ENDIF
				IF columns[i].haskey('columnRenderer') THEN BEGIN 
					IF ((columns[i])['columnRenderer'])['behavior'] EQ "noClientAccess" THEN self.no_Client_Access_list.Add,field->get_name()
				ENDIF
			ENDIF
		ENDFOR

		FOR i=0, n_elements(self.filter_list)-1 DO BEGIN
			name=((self.filter_list)[i]).name
			self.allowed_filter_list.Add,name
		ENDFOR
		FOR i=0, n_elements(self.sort_list)-1 DO BEGIN
			name=((self.sort_list)[i]).name
			self.allowed_sort_list.Add,name
		ENDFOR
		OBJ_DESTROY, oUrl
	ENDELSE
end

function dataset::get_attributes
	compile_opt idl2
	
	attributes={name : self.name,$
			description : self.description,$
			uri : self.uri,$
			url : self.url,$
			status : self.status,$
			fields_list : self.fields_list,$
			fields_struct :self.fields_struct,$
			filter_list :self.filter_list,$
			allowed_filter_list :self.allowed_filter_list,$
			no_Client_Access_list :self.no_Client_Access_list,$
			resources_list :self.resources_list,$
			primary_key: self.primary_key}
	
	return,attributes
end

function dataset::get_url
	compile_opt idl2

	value=''
	if self.url ne '' then value=self.url
	return,value
end

function dataset::get_uri
	compile_opt idl2

	value=''
	if self.uri ne '' then value=self.uri
	return,value
end

function dataset::get_status
	compile_opt idl2

	value=''
	if self.status ne '' then value=self.status
	return,value
end

function dataset::get_fields_struct
	compile_opt idl2

	value=''
	if self.fields_struct ne '' then value=self.fields_struct
	return,value
end


function dataset::search,query_list,output_list,sort_list,limit_request=limit_request_value, limit_to_nb_res_max=limit_to_nb_res_max_value
	compile_opt idl2
	ON_ERROR, 2
	
	i=0;;filter counter
	j=0;;p counter
	IF n_elements(limit_request_value) EQ 0 THEN limit_request=350000 ELSE limit_request=limit_request_value
	IF n_elements(limit_to_nb_res_max_value) EQ 0 THEN limit_to_nb_res_max=-1 ELSE limit_to_nb_res_max=limit_to_nb_res_max_value

	query_hash=HASH('media','json', 'limit', 300, 'start', 0)
	allowed_comp_operation=LIST('LT', 'EQ', 'GT', 'LTE', 'GTE')
	allowed_operation =LIST('DATE_BETWEEN','NUMERIC_BETWEEN', 'CADENCE')
	FOREACH query,query_list DO BEGIN
		operation=STRUPCASE(query->get_operation())
		IF operation EQ 'GE' THEN operation='GTE' ELSE $
		IF operation EQ 'LE' THEN operation='LTE'
		IF allowed_comp_operation.WHERE(operation) NE !NULL THEN BEGIN
			key='filter['+STRCOMPRESS(j, /REMOVE_ALL)+'][columnAlias]'
			value= STRJOIN(STRSPLIT(query->get_name_list_str(), /EXTRACT),"|")
			query_hash+=HASH(key,value)
			key='filter['+STRCOMPRESS(j, /REMOVE_ALL)+'][data][type]'
			value='numeric'
			query_hash+=HASH(key,value)
			key='filter['+STRCOMPRESS(j, /REMOVE_ALL)+'][data][value]'
			value= STRJOIN(STRSPLIT(query->get_value_list_str(), /EXTRACT),"|")
			query_hash+=HASH(key,value)
			key='filter['+STRCOMPRESS(j, /REMOVE_ALL)+'][data][comparison]'
			value=operation
			query_hash+=HASH(key,value)
			j+=1
		ENDIF ELSE IF operation EQ 'LIKE' THEN BEGIN
			operation='TEXT'
			i+=1
		ENDIF ELSE IF operation EQ 'IN' THEN BEGIN 
			operation='LISTBOXMULTIPLE'
			key='p['+STRCOMPRESS(i, /REMOVE_ALL)+']'
			value= operation+"|"+STRJOIN(STRSPLIT(query->get_name_list_str(), /EXTRACT),"|")+"|"+STRJOIN(STRSPLIT(query->get_value_list_str(), /EXTRACT),"|")
			query_hash+=HASH(key,value)
			i+=1
		ENDIF ELSE IF allowed_operation.WHERE(operation) NE !NULL THEN BEGIN
			key='p['+STRCOMPRESS(i, /REMOVE_ALL)+']'
			value= operation+"|"+STRJOIN(STRSPLIT(query->get_name_list_str(), /EXTRACT),"|")+"|"+STRJOIN(STRSPLIT(query->get_value_list_str(), /EXTRACT),"|")
			query_hash+=HASH(key,value)
			i+=1
		ENDIF ELSE BEGIN
			print,'Operation not allowed'	
		ENDELSE	
	ENDFOREACH

	output_name_list=LIST()
	output_name_dict=HASH()
	FOREACH field,output_list DO BEGIN
		output_name_list.Add, field->get_name()
		key=field->get_name()
		value=field
		output_name_dict+=HASH(key,value)
	ENDFOREACH
	out_name_list_str="" 
	FOREACH output, output_name_list DO BEGIN
		out_name_list_str+=output+" "
	ENDFOREACH

	sort_dict_list=LIST()
	FOREACH sort_request,sort_list DO BEGIN	
		sort_name=sort_request[0]->get_name()
		IF self.allowed_sort_list.WHERE(sort_name) EQ !NULL THEN print, "Sort not allowed on this field"
		sort_dictionary=HASH()
 		key='field'
		value= sort_request[0]->get_name()
		sort_dictionary+=HASH(key,value)
		key='direction'
		value= sort_request[1]
		sort_dictionary+=HASH(key,value)
		sort_dict_list.Add,sort_dictionary
	ENDFOREACH

	temp_kwargs=HASH()
	query_hash_sort=HASH()
	key='ordersList'
	value=sort_dict_list
	query_hash_sort+=HASH(key,value)
	key='sort'
	value=query_hash_sort
	temp_kwargs+=HASH(key,value)
	url_sort=''
	FOREACH value,temp_kwargs,key DO BEGIN 
		url_sort+=key+"="+JSON_SERIALIZE(value)+" "
	ENDFOREACH
	url_sort=STRJOIN( STRSPLIT(url_sort, /EXTRACT),"&")
	url_kwargs=''
	FOREACH value,query_hash,key DO BEGIN 
		url_kwargs+=key+'='+STRTRIM(STRING(value),2)+" "
	ENDFOREACH
	url_kwargs=STRTRIM(url_kwargs,2 )
	url_kwargs=STRJOIN(STRSPLIT(url_kwargs, /EXTRACT),"&")

	key_col_Model='colModel'
	value_col_Model=STRJOIN(STRSPLIT(out_name_list_str, /EXTRACT),", ")
	value_col_Model='"'+STRTRIM(value_col_Model, 2)+'"'
	url_col_Model=key_col_Model+"="+value_col_Model

	url_count=self.url+"/count"+'?'+url_kwargs+"&"+url_sort+"&"+url_col_Model;;Build url just for count
	url=self.url+"/records"+'?'+url_kwargs+"&"+url_sort+"&"+url_col_Model;;Build url for the request
	oUrl=OBJ_NEW('IDLnetUrl')
	oUrl.SetProperty, url_scheme='http'
	oUrl.SetProperty, URL_HOST=url_count
	json = oUrl.Get(/STRING_ARRAY)
	json_result=JSON_PARSE(STRJOIN(json))
	nbr_results= json_result['total']
	OBJ_DESTROY, oUrl
	results=LIST() 
	IF (nbr_results LT limit_request) THEN BEGIN;;Check if the request does not exceed 350 000 items 
		IF (limit_to_nb_res_max GT 0) && (limit_to_nb_res_max LT query_hash['limit']) THEN BEGIN 
			query_hash['limit']=limit_to_nb_res_max
			query_hash+=HASH('nocount','true')
			nbr_results=limit_to_nb_res_max
			url_kwargs=''
			FOREACH value,query_hash,key DO BEGIN 
				url_kwargs+=key+'='+STRTRIM(STRING(value),2)+" "
			ENDFOREACH
			url_kwargs=STRTRIM(url_kwargs,2 )
			url_kwargs=STRJOIN(STRSPLIT(url_kwargs, /EXTRACT),"&")
			url=self.url+"/records"+'?'+url_kwargs+"&"+url_sort+"&"+url_col_Model
		ENDIF ELSE IF (limit_to_nb_res_max GT 0 ) &&  (limit_to_nb_res_max GE query_hash['limit']) THEN BEGIN
			PRINT ,"limit of results specified and more than 300"
			nbr_results=limit_to_nb_res_max
			query_hash+=HASH('nocount','true')
			url_kwargs=''
			FOREACH value,query_hash,key DO BEGIN 
				url_kwargs+=key+'='+STRTRIM(STRING(value),2)+" "
			ENDFOREACH
			url_kwargs=STRTRIM(url_kwargs,2 )
			url_kwargs=STRJOIN(STRSPLIT(url_kwargs, /EXTRACT),"&")
			url=self.url+"/records"+'?'+url_kwargs+"&"+url_sort+"&"+url_col_Model
		ENDIF
		oUrl=OBJ_NEW('IDLnetUrl')
		oUrl.SetProperty, url_scheme='http'
		WHILE (nbr_results -query_hash['start']) GT 0 DO BEGIN
			oUrl.SetProperty, URL_HOST=url
			json = oUrl.Get(/STRING_ARRAY)
			json_result=JSON_PARSE(STRJOIN(json))
			FOREACH data_item,json_result['data'] DO BEGIN
				result_dict=HASH()
				FOREACH value,data_item,key DO BEGIN
					IF ( self.no_Client_Access_list.WHERE(key) EQ !NULL AND key NE 'uri' AND output_name_list.WHERE(key) NE !NULL ) OR output_name_list.WHERE(key) NE !NULL THEN BEGIN
						IF STRPOS( output_name_dict[key]->get_type() ,'int',0) EQ 0 THEN BEGIN
							result_dict+=HASH(key, LONG(value))
						ENDIF ELSE IF STRPOS( output_name_dict[key]->get_type() ,'float',0) EQ 0 THEN BEGIN
							result_dict+=HASH(key, FLOAT(value))
						ENDIF ELSE BEGIN
							result_dict+=HASH(key, value)
						ENDELSE

					ENDIF 
				ENDFOREACH
				results.Add,result_dict
			ENDFOREACH
			
			query_hash['start']+= query_hash['limit'];;increment the job by the kwargs limit given (by design)
			url_kwargs=''
			FOREACH value,query_hash,key DO BEGIN 
				url_kwargs+=key+'='+STRTRIM(STRING(value),2)+" "
			ENDFOREACH
			url_kwargs=STRTRIM(url_kwargs,2 )
			url_kwargs=STRJOIN(STRSPLIT(url_kwargs, /EXTRACT),"&")
			url=self.url+"/records"+'?'+url_kwargs+"&"+url_sort+"&"+url_col_Model;; build new url for request
		ENDWHILE
 		OBJ_DESTROY, oUrl
	ENDIF
	return, results
end 


function dataset::execute_plugin, plugin_name=plugin_name_value, pkey_list=pkey_list_value, FILENAME=filename_value
	IF n_elements(plugin_name_value) EQ 0 THEN message,"Provide plugin name" ELSE plugin_name=plugin_name_value
	IF n_elements(pkey_list_value) EQ 0 THEN message,"Provide Pkey list" ELSE pkey_list=pkey_list_value
	IF n_elements(filename_value) EQ 0 THEN message,"Provide FILENAME" ELSE FILENAME=filename_value
	operation='LISTBOXMULTIPLE'
	pkey_list_str=''
	FOREACH pkey,pkey_list DO BEGIN
		pkey_list_str+=STRING(pkey)+" "
	ENDFOREACH
	pkey_list_str=STRJOIN(STRSPLIT(pkey_list_str, /EXTRACT),"|")
	url_key="p[0]="+operation+"|"+self.primary_key->get_name()+"|"+pkey_list_str
	url=self.url+"/"+plugin_name+"?"+url_key
	oUrl_get=OBJ_NEW('IDLnetUrl')
	oUrl_get.SetProperty, url_scheme='http'
	oUrl_get.SetProperty, URL_HOST=url
	file=oUrl_get.Get(FILENAME=FILENAME)
	OBJ_DESTROY, oUrl_get
	return , file
end

pro dataset::resources_list
	compile_opt idl2

	service=(strsplit(self.url,"/",/EXTRACT))[0]
	url=self.url+"/services?media=json"
	oUrl=OBJ_NEW('IDLnetUrl')
	oUrl.SetProperty, url_scheme='http'
	oUrl.SetProperty, URL_HOST=url

  	CATCH, Error_status
	IF (Error_status NE 0) THEN BEGIN
		; Get the properties that will tell us more about the error.
;;		oUrl->GetProperty, RESPONSE_CODE=rspCode, RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
		PRINT , "resources_list() fails, dataset service at ",service," not available."
      ; Destroy the url object
		OBJ_DESTROY, oUrl
		CATCH, /CANCEL
		MESSAGE, /REISSUE_LAST
	ENDIF ELSE BEGIN	
		json = oUrl.Get(/STRING_ARRAY)
		json_result=JSON_PARSE(STRJOIN(json))
		data_result=json_result['data']
		FOREACH data_item, data_result DO BEGIN
			IF  TYPENAME(data_item)  eq 'HASH' THEN BEGIN 
				parameters_data=data_item['parameters']
				FOREACH param, parameters_data DO BEGIN 
					IF TYPENAME(parameters_data) eq 'HASH'THEN BEGIN 
						IF param['name'] EQ 'url' THEN BEGIN
							self.resources_list.Add, self.url+param['value']
						ENDIF
					ENDIF 
				ENDFOREACH
			ENDIF 
		ENDFOREACH
		OBJ_DESTROY, oUrl
		return
	ENDELSE
end


function dataset::get_list, data_list=data_list_value
compile_opt idl2	

IF n_elements(data_list_value) EQ 0 THEN PRINT, "Provide search results please" ELSE data_list=data_list_value

oUrl_get=OBJ_NEW('IDLnetUrl')
oUrl_get.SetProperty, url_scheme='http'
FOREACH data_item, data_list DO BEGIN 
	url_file=(strsplit(data_item['get'],"http://",/EXTRACT, /REGEX))[-1]+";compress=rice"
	oUrl_get.SetProperty, URL_HOST=url_file
	fits_filename='aia.lev1.'+STRCOMPRESS(data_item['wavelnth'], /REMOVE_ALL)+'A_'+data_item['date__obs']+'.Z.image_lev1.fits'
	PRINT, "Downloading "+fits_filename+"..."
	file=oUrl_get.Get(FILENAME=fits_filename)
	
ENDFOREACH
OBJ_DESTROY, oUrl_get
 
return ,1
end

pro dataset__define
	compile_opt idl2

	void={dataset,name : '',$
			description : '',$
			uri : '',$
			url : '',$
			status : '',$
			fields_list : LIST(),$
			fields_struct : OBJ_NEW(),$
			filter_list : LIST(),$
			allowed_filter_list : LIST(),$
			sort_list : LIST(),$
			allowed_sort_list : LIST(),$
			no_Client_Access_list : LIST(),$
			resources_list: LIST(),$
			primary_key: OBJ_NEW()}
 	return
end
