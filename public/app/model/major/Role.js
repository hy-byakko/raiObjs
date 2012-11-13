Ext.define('Vmoss.model.major.Role', {
    extend:'Vmoss.lib.CModel',

    fields:[
        'id',
        'user_id',
        'role_name'
    ],

    proxy:{
        type:'rest',
        url:'/objects/roles'
    }
});