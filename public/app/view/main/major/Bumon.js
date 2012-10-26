Ext.define('Vmoss.view.main.major.Bumon', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel: '部门',

    searchFeature:[
        {field:'bumon_cd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'bumon_mei', xtype:'textfield', maxLength:30},
        {
            field:'bumonlevel_id',
            xtype:'ccombo',
            dispatch:'get_bumon_data'
        }
    ],

    gridFeature:[
        'bumon_cd',
        'bumon_mei',
        'kind',
        'parent',
        'yubin_no',
        'tel_no',
        'fax_no',
        'jusyo'
    ],

    benchFeature:[
        {field: 'bumon_cd', allowBlank: false},
        {field: 'bumon_mei', allowBlank: false},
        {
            field:'bumonlevel_id',
            xtype:'ccombo',
            dispatch:'get_bumon_data'
        },
        {
            field:'parent_id',
            xtype:'ccombo',
            dispatch:'get_parent_data',
            requestParams:[
                'id'
            ]
        },
        'yubin_no',
        'tel_no',
        'fax_no',
        {field:'jusyo', xtype:'textfield',  columnWidth: 2/3}
    ]
});