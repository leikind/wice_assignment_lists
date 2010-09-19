function AssignmentLists(srcListId, destListId, outParamName){

  this.outParamName = outParamName;

  this.srclist  = $('#' + srcListId)[0];
  this.destlist = $('#' + destListId)[0];

  this.parentOfDestList = this.destlist.parentNode;

  this.repopulateListFromJSON = function(newListItems){
    $(this.srclist).children().remove();

    if (newListItems){
      for (i = 0; i < newListItems.length; i++){
        var opt = new Option(newListItems[i][1], newListItems[i][0]);
        this.srclist.options[i] = opt;
      }
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
    $(this.parentOfDestList).children('[type=hidden]').remove();
  }

  this.updateHiddenField = function(){
    this.cleanUpHiddenFields();

    for (i = 0; i < this.destlist.length; i++){
      var str = '<input type="hidden" value="' + this.destlist.options[i].value + 
        '" name="' + this.outParamName + '[]" />';
      $(this.parentOfDestList).append(str);
    }
  }

  this.values = function(){
    return $.makeArray($.map($(this.parentOfDestList).children('[type=hidden]'), function(e){return e.value}));
  }
}
