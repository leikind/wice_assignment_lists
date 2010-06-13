function AssignmentLists(srcListId, destListId, outParamName){

  this.outParamName = outParamName;
  this.srclist  = $(srcListId); //pt
  this.destlist = $(destListId);//pt

  this.parentOfDestList = this.destlist.parentElement;

  this.hiddenFields = new Array();

  this.repopulateListFromJSON = function(newListItems){
    this.srclist.update('');
    var srclist = this.srclist;
    var opt;
    if (newListItems){
      newListItems.each(function(element, i){ // pt
        opt = new Option(element[1], element[0]);
        srclist.options[i] = opt;
      });
    }
  }

  this.moveElementBetweenLists = function(mode){

    if (mode == 1){
      from = this.destlist;
      to   = this.srclist;
    }else{
      from = this.srclist;
      to   = this.destlist;
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
    var parentOfDestList = this.parentOfDestList;
    this.hiddenFields.each(function(element){ // pt
      parentOfDestList.removeChild(element)
    });

    this.hiddenFields = new Array();
  }

  this.updateHiddenField = function(){
    this.cleanUpHiddenFields();

    for (i = 0; i < this.destlist.length; i++){

      el = new Element('input', { // pt
        name: this.outParamName + '[]',
        type: 'hidden',
        value: this.destlist.options[i].value
      });
      this.hiddenFields[i] = el;
      this.parentOfDestList.appendChild(el);
    }
  }

  this.values = function(){
    return this.hiddenFields.collect(function(hf){ return hf.value }); // pt
  }
}
