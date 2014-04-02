
function sitools2Instance::init,value
	compile_opt idl2
	self.url=ptr_new(/allocate)
	if n_elements(value) ne 0 then *(self.url)=value
	return,1
end

pro sitools2Instance::set,value
	compile_opt idl2
 	if n_elements(value) ne 0 then *(self.url)=value
 	return 
end

function sitools2Instance::get,value
	compile_opt idl2
	if n_elements(*(self.url)) ne 0 then value=*(self.url)
	return,value
end

function sitools2Instance::list_project 
	sitools_url=*(self.url)
	data_result=LIST()
	result=LIST()
	str_url=sitools_url+'/sitools/portal/projects'+'?media=json'
	oUrl=OBJ_NEW('IDLnetUrl')
	oUrl.SetProperty, url_scheme='http'
	oUrl.SetProperty, URL_HOST=str_url
	json = oUrl.Get(/STRING_ARRAY)
	json_result=JSON_PARSE(STRJOIN(json))
	print, STRTRIM(json_result['total'],2 ) +" projets detected"
	data_result=json_result['data']
	for i=0, n_elements(data_result)-1 do begin 
		IF  TYPENAME(data_result[i])  eq 'HASH' THEN BEGIN 
			url_project=sitools_url+(data_result[i])['sitoolsAttachementForUsers']
			result.Add,obj_new('project',url_project)
		ENDIF
	endfor
	OBJ_DESTROY, oUrl
	return, result
end 

pro sitools2Instance::cleanup
	compile_opt idl2
	ptr_free,self.url
	return
end 

pro sitools2Instance__define
	compile_opt idl2
	void={sitools2Instance,url:ptr_new()}
 	return
end
