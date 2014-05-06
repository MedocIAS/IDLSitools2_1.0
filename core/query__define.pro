
function query::init,param_list
	compile_opt idl2

	self.fields_list=LIST()
	self.name_list=LIST()
	self.value_list=LIST()
	self.name_list_str=''
	self.value_list_str=''
	self.operation=''
	self->compute_attributes,param_list
	return,1
end

pro query::compute_attributes,param_list
	compile_opt idl2

  	CATCH, Error_status
	IF (Error_status NE 0) THEN BEGIN
		PRINT , "query::compute_attributes() fails."
		OBJ_DESTROY, oUrl
		CATCH, /CANCEL
		MESSAGE, /REISSUE_LAST
	ENDIF 
	self.fields_list=LIST(param_list[0], /EXTRACT)
	self.value_list=LIST(param_list[1], /EXTRACT)
	FOREACH element,self.value_list DO BEGIN
		self.value_list_str+=STRCOMPRESS(element, /REMOVE_ALL)+" " 
	ENDFOREACH
	self.value_list_str=STRTRIM(self.value_list_str,2 )
	self.operation=param_list[2]

	FOREACH element, self.fields_list DO BEGIN
		self.name_list.Add ,element->get_name()
		self.name_list_str+=element->get_name()+" "
	ENDFOREACH
	self.name_list_str=STRTRIM(self.name_list_str,2 )
	return
end

function query::get_fields_list
	compile_opt idl2

	value=LIST()
	if n_elements(self.fields_list) ne 0 then value=self.fields_list
	return,value
end

function query::get_name_list_str
	compile_opt idl2

	value=''
	if n_elements(self.name_list_str) ne 0 then value=self.name_list_str
	return,value
end

function query::get_value_list_str
	compile_opt idl2

	value=''
	if n_elements(self.value_list_str) ne 0 then value=self.value_list_str
	return,value
end

function query::get_operation
	compile_opt idl2

	value=LIST()
	if n_elements(self.operation) ne 0 then value=self.operation
	return,value
end

function query::get_attributes
	compile_opt idl2
	
	attributes={fields_list : self.fields_list, name_list: self.name_list, value_list : self.value_list, operation :self.operation}	
	return,attributes
end

pro query__define
	compile_opt idl2
	void={query, fields_list :LIST(), name_list :LIST(), value_list : LIST(), operation : '', name_list_str:'', value_list_str :''}
 	return
end
