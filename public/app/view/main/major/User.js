Ext.define('Vmoss.view.main.major.User', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel: '用户',

    searchFeature:[
        {field:'user_cd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'user_name', xtype:'textfield', maxLength:30},
        {
            field:'bumon_id',
            association: 'Vmoss.model.major.Department',
            display:'bumon_mei',
            xtype:'ccombo'
        }
    ],

    gridFeature:[
        'user_cd',
        'user_name',
        'department_name',
        'birth_dtm',
        'nyusya_dtm',
        'tel_no',
        'email'
    ],

    benchFeature:[
        {field: 'user_cd', allowBlank: false},
        {field: 'user_name', allowBlank: false},
        {
            field:'bumon_id',
            association: 'Vmoss.model.major.Department',
            display:'bumon_mei',
            xtype:'ccombo'
        },
        'birth_dtm',
        'nyusya_dtm',
        'tel_no',
        'email'
    ]
});