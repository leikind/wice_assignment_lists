var AssignmentLists = Class.create({

  initialize: function(srcListId, destListId, outParamName){
    this.outParamName = outParamName;
    this.srclist  = $(srcListId);
    this.destlist = $(destListId);
    this.f = this.destlist.form;

    this.hiddenFields = new Array();
  },

  repopulateListFromJSON: function(newListItems){
    this.srclist.update('');
    var opt;
    if (newListItems){
      newListItems.each(function(element, i){
        opt = new Option(element[1], element[0]);
        this.srclist.options[i] = opt;
      }.bind(this));
    }
  },

  moveElementBetweenLists:  function(mode){

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
  },

  cleanUpHiddenFields:  function(){ 
    this.hiddenFields.each(function(element){
      this.destlist.form.removeChild(element)
    }.bind(this));
    
    this.hiddenFields = new Array();
  },

  updateHiddenField: function(){
    this.cleanUpHiddenFields();
    for (i = 0; i < this.destlist.length; i++){
      
      el = new Element('input', { 
        name: this.outParamName + '[]',
        type: 'hidden',
        value: this.destlist.options[i].value
      });
      
      this.hiddenFields[i] = el;
      this.f.appendChild(el);
    }
  },

  values: function(){
    return this.hiddenFields.collect(function(hf){ return hf.value });
  }
})
