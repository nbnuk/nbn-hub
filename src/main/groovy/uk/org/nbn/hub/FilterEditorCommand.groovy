package uk.org.nbn.hub

import grails.databinding.BindUsing

class FilterEditorCommand {
    @BindUsing({ obj, source ->
        source['fq'] ? ((source['fq'] instanceof String) ? [source['fq']] : source['fq']): [] as String[]
    })
    String[] fq
    String qc
    Integer offset
    Integer max
    String sort
}
