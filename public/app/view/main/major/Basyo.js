Ext.define('Vmoss.view.main.major.Basyo', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel:'点位',

    searchFeature:[
        {field:'basyo_cd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'basyo_name', xtype:'textfield', maxLength:30},
        {
            field:'customer_id',
            xtype:'ccombo',
            dispatch:'get_customer'
        },
        {
            field:'vm_id',
            xtype:'ccombo',
            dispatch:'get_vm'
        },
        {
            field:'bumon_id',
            xtype:'ccombo',
            dispatch:'get_bumon'
        },
        {
            field:'eigyotanto_id',
            xtype:'ccombo',
            dispatch:'get_eigyotanto'
        },
        {
            field:'sagyotanto_id',
            xtype:'ccombo',
            dispatch:'get_sagyotanto'
        },
        {
            field:'rireki_dtm',
            xtype:'datefield',
            label:'作业日',
            format:'Y/m/d',
            value:Ext.Date.format(new Date(), 'Y/m/d'),
            listeners:{
                change:function(){
                    console.log(arguments);
                }
            }
        }
    ],

    gridFeature:[
        'customer_name',
        'basyo_cd',
        'basyo_name',
        'rireki_kaisi_dtm',
        'rireki_syuryo_dtm',
        {field:'bumon_name', label:'管辖部门'},
        'eigyotanto_name',
        'vm_cd',
        'sagyotanto_name'
    ],

    benchFeature:[
        {field:'basyo_cd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'basyo_name', xtype:'textfield', maxLength:30},
        {
            field:'customer_id',
            xtype:'ccombo',
            dispatch:'get_customer'
        },
        {
            field:'vm_id',
            xtype:'ccombo',
            dispatch:'get_vm'
        },
        {
            field:'bumon_id',
            xtype:'ccombo',
            dispatch:'get_bumon'
        },
        {
            field:'eigyotanto_id',
            xtype:'ccombo',
            dispatch:'get_eigyotanto'
        },
        {
            field:'sagyotanto_id',
            xtype:'ccombo',
            dispatch:'get_sagyotanto'
        }
    ]
});