Ext.define('Vmoss.view.main.major.User', {
    extend:'Vmoss.view.main.Standard',


    instanceLabel: '用户',

    searchFeature:[
        {field:'user_cd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'user_name', xtype:'textfield', maxLength:30}
    ],

    gridFeature:[
        'user_cd',
        'user_name',
        'bumon_id',
        'birth_dtm',
        'nyusya_dtm',
        'tel_no',
        'email'
    ],

    benchFeature:[
        {field: 'user_cd', allowBlank: false},
        {field: 'user_name', allowBlank: false},
        'bumon_id',
        'birth_dtm',
        'nyusya_dtm',
        'tel_no',
        'email'
    ]
});