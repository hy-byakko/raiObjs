Ext.define('Vmoss.model.major.Department', {
    extend:'Vmoss.lib.CModel',

    fields:[
        'id',
        'bumon_mei'
    ],

    proxy:{
        type:'rest',
        url:'/objects/departments'
    }
});