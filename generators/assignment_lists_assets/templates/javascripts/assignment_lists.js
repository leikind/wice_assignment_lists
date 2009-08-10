AssignmentLists = function(srcListId, destListId, outParamName){
        
  var srclist  = $(srcListId);
  var destlist = $(destListId);
  var f = destlist.form;

  var hiddenFields = new Array();

  this.repopulateListFromJSON = function(json){
    while (srclist.length != 0){
      srclist.options[0] = null;
    }
    var newListItems = eval('(' + json + ')');
    var opt;
    if (newListItems){
      newListItems.each(function(element, i){
        opt = new Option(element[1], element[0]);
        srclist.options[i] = opt;
      });
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
    hiddenFields.each(function(element){
      destlist.form.removeChild(element)
    });
    
    hiddenFields = new Array();
  }

  this.updateHiddenField = function(){
    this.cleanUpHiddenFields();
    destlist.each(function(element,i){
      
      el = new Element('input', { 
        name: outParamName + '[]',
        type: 'hidden',
        value: element.value
      });
      
      
      hiddenFields[i] = el;
      f.appendChild(el);
    })
  }

  this.values = function(){
    return hiddenFields.collect(function(hf){ return hf.value });
  }
}
