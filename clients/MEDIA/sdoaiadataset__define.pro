
function  sdoaiadataset::init
	compile_opt idl2
	self.sitools2_url="medoc-sdo.ias.u-psud.fr"
	self.aia_dataset_uri="/webs_aia_dataset"
	aia_url=self.sitools2_url+self.aia_dataset_uri
	aia_dataset_code=self->dataset::init(aia_url)
	
	return,aia_dataset_code
end

function sdoaiadataset::get_sitools2_url
	compile_opt idl2
	
	value=''
	if self.sitools2_url ne '' then value=self.sitools2_url
	return,value
	
end

function sdoaiadataset::get_aia_dataset_uri
	compile_opt idl2
	
	value=''
	if self.aia_dataset_uri ne '' then value=self.aia_dataset_uri
	return,value
	
end

pro sdoaiadataset__define
	compile_opt idl2

	void={sdoaiadataset, sitools2_url : '', aia_dataset_uri :'', INHERITS dataset}
 	return
end
