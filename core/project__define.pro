
function project::init,url
	compile_opt idl2

	self.name=''
	self.description=''
	self.uri=''
	self.url=''
	self.resources_target=LIST()
	self->compute_attributes,url
	return,1
end


pro project::compute_attributes,url
	compile_opt idl2
	self.uri="/"+(strsplit(url,"/",/EXTRACT))[-1]
	self.url=url
	str_url=self.url+'?media=json'
	oUrl=OBJ_NEW('IDLnetUrl')
	oUrl.SetProperty, url_scheme='http'
	oUrl.SetProperty, URL_HOST=str_url
	json = oUrl.Get(/STRING_ARRAY)
	json_result=JSON_PARSE(STRJOIN(json))
	result=json_result['project']
	self.name=result['name']
	self.description=result['description']
	OBJ_DESTROY, oUrl
end

function project::get_attributes
	compile_opt idl2
	
	attributes={name : self.name, description: self.description, uri : self.uri, url :self.url, resources_target :self.resources_target}	
	return,attributes
end


pro project::resources_list
	compile_opt idl2
	
	PRINT, "IN progress"
	
end

function project::dataset_list
	compile_opt idl2

	result=LIST()
	data_result=LIST()
	str_url=self.url+'/datasets'+'?media=json
	oUrl=OBJ_NEW('IDLnetUrl')
	oUrl.SetProperty, url_scheme='http'
	oUrl.SetProperty, URL_HOST=str_url
	json = oUrl.Get(/STRING_ARRAY)
	json_result=JSON_PARSE(STRJOIN(json))
	data_result=json_result['data']
;;	PRINT, JSON_SERIALIZE(data_result)
	
	for i=0, n_elements(data_result)-1 do begin 
		IF  TYPENAME(data_result[i])  eq 'HASH' THEN BEGIN
			url_dataset=(strsplit(self.url,"/",/EXTRACT))[0]+(data_result[i])['url']
			dataset=obj_new('dataset',url_dataset)
			result.Add, dataset
;;			PRINT, JSON_SERIALIZE(data_result)
		ENDIF
	endfor
	OBJ_DESTROY, oUrl
	return, result

end

pro project__define
	compile_opt idl2
	void={project, name :'', description :'', uri : '', url :'', resources_target:LIST()}
 	return
end
