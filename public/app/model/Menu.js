Ext.define('Vmoss.model.Menu', {
    extend:'Vmoss.lib.CModel',

    fields:[
        {name:'text', type:'string'},
        {name:'singleClickExpand', type:'bool'},
        {name:'leaf', type:'bool', defaultValue:false},

        {name:'model', type:'string'}
    ]
});
