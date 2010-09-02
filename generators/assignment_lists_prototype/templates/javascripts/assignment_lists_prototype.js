function AssignmentLists(srcListId, destListId, outParamName){

  this.outParamName = outParamName;
  this.srclist  = $(srcListId);
  this.destlist = $(destListId);

  this.parentOfDestList = this.destlist.parentNode;

  this.repopulateListFromJSON = function(newListItems){
    this.srclist.update('');
    var srclist = this.srclist;
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
    Selector.findChildElements(this.parentOfDestList, ['input[type=hidden]']).invoke('remove');
  }

  this.updateHiddenField = function(){
    this.cleanUpHiddenFields();

    for (i = 0; i < this.destlist.length; i++){
      var str = '<input type="hidden" value="' + this.destlist.options[i].value + 
        '" name="' + this.outParamName + '[]" />';
      this.parentOfDestList.insert({bottom: str});
    }
  }

  this.values = function(){
    return Selector.findChildElements(this.parentOfDestList, ['input[type=hidden]']).collect(function(hf){
      return hf.value;
    });
  }
}
