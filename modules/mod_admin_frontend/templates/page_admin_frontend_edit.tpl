{% extends "base_frontend_edit.tpl" %}

{% block title %}{_ Edit _}{% if id %}: {{ id.title|default:"-" }}{% elseif tree_id %}: {{ tree_id.title|default:"-" }}{% endif %}{% endblock%}

{% block html_head_extra %}
	{% lib 
			"css/zp-menuedit.css" 
			"css/zotonic-admin.css" 
			"css/admin-frontend.css" 
			"css/jquery-ui.datepicker.css"
            "css/jquery.timepicker.css"
            "font-awesome/css/font-awesome.min.css"
	%}
{% endblock %}

{% block content_area %}
	{% with tree_id|default:(id|menu_rsc) as tree_id %}
	{% with `none` as admin_menu_edit_action %}
	<div class="row-fluid">
		{% with m.rsc[tree_id].id as tree_id %}
			{% if tree_id and tree_id.is_visible %}
				<div class="span4" id="menu-editor" data-rsc-id="{{ tree_id }}">
					{% block above_menu %}{% endblock%}
			        {% catinclude "_admin_menu_menu_view.tpl" tree_id connect_tab="new" cat_id=m.rsc.text.id admin_menu_edit_action=admin_menu_edit_action %}
					{% block below_menu %}{% endblock%}
				</div>
				<div class="span8" id="editcol">
				{% block editcol %}
					{% if id %}
						<p><img src="/lib/images/spinner.gif" width="16" /> {_ Loading ... _}</p>
						{% javascript %}
							document.z_default_edit_id = {{ id }};
						{% endjavascript %}
					{% else %}
						{% include "_admin_frontend_nopage.tpl" tree_id=tree_id %}
					{% endif %}
				{% endblock %}
				</div>
			{% elseif id %}
				<div class="span12" id="editcol">
					<p><img src="/lib/images/spinner.gif" width="16" /> {_ Loading ... _}</p>
					{% javascript %}
						document.z_default_edit_id = {{ id }};
					{% endjavascript %}
				</div>
			{% endif %}
		{% endwith %}
	</div>
	{% endwith %}
	{% endwith %}
	{% include "_admin_edit_js.tpl" %}
{% endblock %}

{% block navbar %}
{# The buttons in the navbar click/sync with hidden counter parts in the resource edit form #}
<nav class="navbar navbar-fixed-top">
	<div class="navbar-inner">
	<div class="container-fluid">
		<div class="row-fluid">
			{% if tree_id %}
				<div class="span4">
					{% block close_button %}
						{% if id.is_temporary %}
							<a href="{% url mx_resource_cleanup id=id %}" class="btn">{_ Close _}</a>
						{% else %}
							<a href="{{ id.page_url }}" class="btn">{_ Close _}</a>
						{% endif %}
					{% endblock %}
				</div>
				<div class="span8" id="save-buttons" style="display:none">
			{% else %}
				<div class="span12" id="save-buttons" style="display:none">
			{% endif %}
				<span class="brand visible-desktop">{_ This page _}</span>

				{% button class="btn btn-primary" text=_"Save" title=_"Save this page." 
						  action={script script="$('#save_stay').click();"}
				 %}

				{% button class="btn" text=_"Save &amp; view" title=_"Save and view the page." 
						  action={script script="$('#save_view').click();"}
				 %}

				{% if id.is_temporary %}
					<a href="{% url mx_resource_cleanup id=id %}" class="btn">{_ Cancel _}</a>
				{% elseif not tree_id %}
					<a href="{{ id.page_url }}" class="btn">{_ Cancel _}</a>
				{% else %}
					{% button class="btn pull-right" text=_"Cancel" action={redirect back} tag="a" %}
				{% endif %}
	    	</div>
		</div>
	</div>
	</div>
</nav>
{% endblock %}

{% block _js_include_extra %}
	{% lib
		"js/qlobber.js"
		"js/pubzub.js"

    	"js/modules/jquery.hotkeys.js"
	    "js/modules/z.adminwidget.js"
	    "js/modules/z.tooltip.js"
	    "js/modules/z.feedback.js"
	    "js/modules/z.formreplace.js"
	    "js/modules/z.datepicker.js"
	    "js/modules/z.menuedit.js"
	    "js/modules/z.cropcenter.js"
	    "js/modules/z.formdirty.js"
	    "js/modules/jquery.shorten.js"
	    "js/modules/jquery.timepicker.min.js"

	    "js/apps/admin-common.js"
	    "js/modules/admin-frontend.js"
	%}
	{% lib
	    "js/jquery.ui.nestedSortable.js"
	%}
	{% all include "_admin_lib_js.tpl" %}
	{% include "_editor.tpl" is_editor_include %}

	{% javascript %}
	    window.z_translations = window.z_translations || {};
	    window.z_translations["Yes, discard changes"] = "{_ Yes, discard changes _}";
	    window.z_translations["There are unsaved changes. Are you sure you want to leave without saving?"]
	    	= "{_ There are unsaved changes. Are you sure you want to leave without saving? _}";
	{% endjavascript %}

{% endblock %}
