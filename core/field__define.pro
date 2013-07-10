
function field::init,hash
	compile_opt idl2

	self.name=''
	self.sitools2_type=''
	self.filter=''
	self.sort=''
	self.behavior=''
	self->compute_attributes,hash
	return,1
END

pro field::compute_attributes,dictionary
	compile_opt idl2
	
	IF dictionary.haskey('columnAlias') THEN self.name=dictionary['columnAlias']
	IF dictionary.haskey('sqlColumnType') THEN self.sitools2_type=dictionary['sqlColumnType']
	IF dictionary.haskey('filter')THEN self.filter=dictionary['filter']
	IF dictionary.haskey('sortable') THEN self.sort=dictionary['sortable']
	IF dictionary.haskey('columnRenderer' ) THEN BEGIN 
		self.behavior=(dictionary['columnRenderer'])['behavior']
	ENDIF
END

function field::get_name
	compile_opt idl2
	
	value=self.name 
	return,value
end

function field::get_type
	compile_opt idl2
	
	value=self.sitools2_type
	return,value
end

function field::get_attributes
	compile_opt idl2
	
	attributes={name : self.name, sitools2_type: self.sitools2_type, filter : self.filter, sort :self.sort, behavior :self.behavior}	
	return,attributes
end


pro field__define
	compile_opt idl2

	void={field, name :'', sitools2_type :'', filter : '', sort : '' , behavior :''}
 	return
END
