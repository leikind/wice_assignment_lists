AssignmentLists = function(srcListId, destListId, outParamName){
        
	var srclist  = document.getElementById(srcListId);
	var destlist = document.getElementById(destListId);
	var f = destlist.form;

	var hiddenFields = new Array();

	this.repopulateListFromJSON = function(json){
		while (srclist.length != 0){
			srclist.options[0] = null;
		}
		var newListItems = eval('(' + json + ')');
		if (newListItems){
			for(var i=0; i < newListItems.length; i++ ){
				var opt = new Option(newListItems[i][1], newListItems[i][0]);
				srclist.options[i] = opt;
			}
		}
	}

	this.moveElementBetweenLists = function(mode){

		if (mode == 1){
			from = destlist;
			to   = srclist;
		}else{
			from = srclist;
			to   = destlist;
		}

		var i = 0;
		while (i < from.length){
			if (from.options[i].selected) {
				var nd = to.length;
				var opt = new Option(from.options[i].text, from.options[i].value);
				to.options[nd] = opt;
				from.options[i] = null;
			} else  i++;
		}
		this.updateHiddenField();
	}

	this.cleanUpHiddenFields = function(){ 
		for (i = 0; i < hiddenFields.length; i++){
			destlist.form.removeChild(hiddenFields[i]);
		}
		hiddenFields = new Array();
	}

	this.updateHiddenField = function(){
		this.cleanUpHiddenFields();
		for (i = 0; i < destlist.length; i++){
			el = document.createElement('input');
			el.name = outParamName + '[]';
			el.type = 'hidden';
			el.value = destlist.options[i].value;
			hiddenFields[i] = el
			f.appendChild(el);
		}
	}

	this.values = function(){
		return hiddenFields.collect(function(hf){ return hf.value });
	}
}
