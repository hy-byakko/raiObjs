Ext.define('Vmoss.view.main.major.Bumon', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel: '部门',

    searchFeature:[
        {field:'cd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'name', xtype:'textfield', maxLength:30},
        {
            field:'kindId',
            xtype:'ccombo',
            dispatch:'get_bumon_data',

            forceSelection:true,
            selectOnFocus:true,
            editable:true
        }
    ],

    gridFeature:[
        'cd',
        'name',
        'kind',
        'parent',
        'yubinNo',
        'telNo',
        'faxNo',
        'jusyo'
    ],

    benchFeature:[
        'cd',
        'name',
        {
            field:'kindId',
            xtype:'ccombo',
            dispatch:'get_bumon_data',

            forceSelection:true,
            selectOnFocus:true,
            editable:true
        },
        'parent',
        'yubinNo',
        'telNo',
        'faxNo',
        'jusyo'
    ]
});